# Proof of concept Infrastructure as Code - Mongo Cluster

### Summary
Demonstration of a mongo cluster using terraform, ansible, and docker
This assumes that the network has already been created, i.e. there is already
a working VPC with subnets and Route53 domain.
The terraform aws ec2 module and security group is adapted

### Tools
* Terraform - Provision EC2 instances, security groups, EBS volumes, and DNS
* Docker - Used to deploy versioned Mongo image
* Ansible - Automated deployment of Docker images to cluster
* Mongo - Use mongo 3.4

### Prerequisites
```
$ terraform --version
Terraform v0.11.2
$ docker --version
Docker version 17.09.0-ce, build afdb6d4
$ ansible --version
ansible 2.0.0.2
```

### Instructions
1. Terraform is used to initially provision resources
```
$ terraform init
$ terraform plan
$ terraform apply 
```
This provisions a mongo cluster of `${var.count}` nodes, each having a
`${var.ebs_volume_size}` EBS volume, and a route53 A record for each node.
User data mounts EBS to `/data` for persistence of mongo data.

2. The mongo3.4 container is edited such that it mounts the `/data/db`
directory and outputs logs to `/data/logs` for persistence. An automatic
build can be set up for this container on dockerhub/dockercloud such that
each repository commit re-builds the docker image. Otherwise, this can
be done manually with
```
$ docker build -t test/mongo-cluster .
$ docker login
$ docker push test/mongo-cluster
```

3. Although it is often preferrable to use a container orchestrator/scheduler
for container deploys, the ansible `docker_container` module can suffice
for one off deployments. Run the following command in the `playbooks`
directory once the `mongo-cluster` image has been pushed. The ansible playbook
uses the `ec2.py` tag grouping in order to reach all nodes tagged with
`ansibleGroup:mongoCluster` key:value.

```
$ ansible-playbook mongo-cluster.yml
```

4. Clustering the mongo cluster is not yet automated and can be done by
ssh-ing into a mongo instance  and running the following commands.
This will create a leader node and two secondary nodes.
Note: You may have to use the IP address if the DNS record is not live yet.
```
$ docker exec -it mongo bash
$ mongo
$ rs.initiate( {
   _id : "rs0",
   members: [               
      { _id: 0, host: "mongo-cluster-0.test.com:27017" }, 
      { _id: 1, host: "mongo-cluster-1.test.com:27017" },
      { _id: 2, host: "mongo-cluster-2.test.com:27017" }
   ]
})
```

### Improvements
Since this was a demonstration, there are multiple areas of improvement
* Register EC2 instances in an ASG with a load balancer
    * DNS records update dynamically if multiple nodes are created/destroyed
* Store the terraform state file in an S3 bucket
* Automatic clustering of mongo nodes
* container orchestration for deployments
* for high IOPS optimization the host network can be used for the mongo
