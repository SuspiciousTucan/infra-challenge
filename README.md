# Hivemind's Infrastructure Challenge

The challenge consists in deploying a web service in a highly available environment using ECS or EKS.

- Deploy to AWS using Terraform or CDK.

- Set `HELLO_TAG` to a unique value.

- See if you can capture logs.

- Bonus points if you add a url parameter to the greeter.

We should be able to deploy your solution in any AWS account.

## Building the application

You can build and run a go app in many ways, easiest is the following:

    go build -o greeter greeter.go
    ./greeter

## Resources

- [AWS Cloud Development Kit](https://aws.amazon.com/cdk/)

# Solution

<p>The solution chosen to deploy the application uses EKS as environment and Terraform for its deployment. Cluster creation was delegated to a dedicated terraform module. Even though best practices wouldn't want me reinventing the wheel when possible, I have chosen not to use already developed modules such as those available at [aws-terraform-modules](https://github.com/terraform-aws-modules) or other tools such as eksctl. The reasoning is simple, this modules and tools provide an abstraction and as such they tend to hide a lot of the important details that go in bootstrapping a new cluster on AWS.

<p>NB: <b>For now the module supports only the us-east-1 region and is generally quite fragile. I suggest sticking to the provided values that have been tested to work.</b>

<p>I've also included a sample value file for terraform and helm. Generally speaking this files shouldn't be
committed to VCS.

## Table of Contents  
1) [Vagrant environment](#vagrant-environment)

    1.1) [Installation](#vagrant1-1)

    1.2) [Environment provisioning](#vagrant-1-2)

    1.3) [Accessing environment](#vagrant-1-3)

    1.4) [Clean up](#vagrant-1-4)

2) [How to demo](#how-to-demo)

3) [Problems and improvements](#problems-and-improvements)

4) [Known bugs](#known-bugs)

## Vagrant environment


<p><a href="https://www.vagrantup.com/" target="_blank">Vagrant</a> is a tool used to provision virtual environments. It is useful to provide developers with an easily reproducible environment with all the required tools to develop and build the project. The state of the project directory in the virtual environment is synchronized with that of the host to preserve changes without any further action. Furthermore the vagrant imports the <code>~/.ssh/</code> and <code>~/.aws</code> directories in the virtual host <b>without</b> synchronizing them. This is to avoid loss of important data on the host machine.
<p>The environment comes with the following packages pre installed :

<ul>
    <li>aws-cli (version 2.7.31)</li>
    <li>kubectl (version 1.25)</li>
    <li>terraform (version 1.2.9)</li>
    <li>docker (version 20.10.18)</li>
    <li>go (version 1.19.1)</li>
    <li>helm (version 3.9.4)</li>
    <li>eksctl (version 0.112.0)</li>
</ul>


#### Installation

<p>Please refer to the <a href="https://www.vagrantup.com/downloads" target="_blank">download page</a> to install vagrant on your system. Version used was <code>2.2.18</code>.



#### Environment provisioning

<p>To create a new Vagrant machine enter the <code>./vagrant</code> directory and lunch <code>vagrant up</code>. The whole process might take a few minutes the first time as Vagrant downloads the box image. In case the machine was already created it is possible to re run the provisioning process by adding the <code>--provision</code> flag.



#### Accessing provisioned environment

<p>Once created we can access the virtual machine using <code>vagrant ssh</code>. This will establish a new ssh session with the guest host.



#### Clean up

<p>To suspend the environment run <code>vagrant suspend</code>, this will hibernate the guest machine while preserving its RAM. To shut down completely use <code>vagrant halt</code>. Use <code>vagrant destroy</code> to stop and remove all traces of the guest host.




## How to demo
<p>First thing bootstrap the vagrant environment and login through ssh. Once in the virtual machine authenticate to AWS using the CLI, this is necessary if the host machine doesn't have a <code>~/.aws/credentials</code> directory.
<p>Enter the <code>./terraform</code> directory and initialize terraform's modules using <code>terraform init</code> (might not be necessary tho). Once terraform has been initialize run <code>terraform plan --var-file ./env/dev.tfvars -out dev.plan && terraform apply dev.plan</code>. The whole process takes roughly 20 minutes.
<p>Once terraform has finished, return to the root of the project and install its helm chart in the cluster. This can be easily achived via <code>helm install -f helm-values.yml demo .</code>




## Problems and improvements
<p>The solution proposed lacks certain important features that haven't yet been implemented and is definitely not problem free. Following is a brief list of features that should be either reworked or implemented all together.
<ul>
    <li>
        <p><h5>NACL &amp; Security Groups</h5>
        <p>Security groups for the various nodes and control plane components are extremely permissive at the moment. This is very problematic for security as no checks are performed on inbound or outbound traffic. NACL are not implemented, similarly to security groups, they offer stateless firewalling at the subnet level, rather than at the instance level.
    </li>
    <li>
    <p>The golang server should not bind to port 80 or 443, which require root permissions to do. A better approach would be to listen on ports greater than 1023. The Pod should then be provided with a security context to ensure the right user/group are running the server.</li>
    </li>
    <li>
      <p> Pods should have a Pod Topology Spread Constraints in order to guarantee that pods are evenly distributed throughout all aws availability zones.
    </li>
    <li>
        <p><h5>Helm chart repository</h5>
        <p>As of now depoyment of the application has to be done manually. This is because there is not an external registry hosting the chart. One easy solution would be using gitlab as it offers a built-in chart registry. Another solution could be using the S3 service from AWS to host the charts.
    </li>
    <li>
        <p><h5>Enable IAM roles for service account</h5>
    </li>
    <li>
        <p><h5>Deploy bastion host/VPN server for secure remote access</h5>
    </li>
    <li>
        <p><h5>Performance monitoring and visualization</h5>
    </li>
    <li>
        <p><h5>CI/CD Pipeline</h5>
        <p>No CI/CD pipeline was configured for the project
    </li>
</ul>


## Known bugs
<p>The docker provider sometimes fails to build the image on my machine. No clue as to why this happens. The reporter error is :
<br>
<pre>╷
│ Error: Provider produced inconsistent final plan
│
│ When expanding the plan for docker_registry_image.hivemind_hiring_challange to include new values learned so far during apply, provider "registry.terraform.io/kreuzwerker/docker"
│ produced an invalid new value for .build[0].context: was cty.StringVal("..:3d1f2293c90da4ee925f4137accc937a66941053cc71abf79e8ee4d9b5cc3cff"), but now
│ cty.StringVal("..:c9359a29079ef79247198cf459566adffd3aa38c330fbadcdd45af7919ed992a").
│
│ This is a bug in the provider, which should be reported in the provider's own issue tracker.
</pre>

<p>Sometimes terraform fails to authenticate to AWS with the following message:
<pre>"Signature expired: 20220921T155248Z is now earlier than 20220921T155450Z (20220921T155950Z - 5 min.)"</pre>
<p>This is caused by inconsistencies in time between the vagrant host and the AWS services. To fix it try running <code>sudo rm /etc/localtime && sudo ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime</code>

<p>Sometimes invoking docker results in a permission denied error. This is normally expected as the current user has to belong to the docker group in order to avoid the root user. That said, even if the vagrant user is added to the docker group using <code>usermod -a -G docker vagrant</code>, the error still persist. Use sudo if necessary to bypass this limitation. Another work around that seems to work is simply loggin out of the box and logging back in.

<p>When invoking <code>terraform destroy</code> the following error is returned : <br>
<pre>
Get "http://localhost/api/v1/namespaces/aws-load-balancer-controller": dial tcp 127.0.0.1:80: connect: connection refused</pre>.<br>
The error is triggered by tring to delete the namespaces previously created. It seems like terraform can't connect to the K8s cluster. My current work around, inspired by (https://github.com/terraform-aws-modules/terraform-aws-eks/issues/978), is to manually remove problematic resources and re run the destroy command.
<p>To manually remove a resource from Terraform's state run <code>terraform state rm resource_type.resource_name</code>.

## Cheats

<p>Following are some usefull commands to manage different aspects of the project.
<ul>
    <li>
        <p><h5>Generate kubeconfig after cluster bootstrap</h5>
        <p><code>aws eks update-kubeconfig --region $region --name $name</code>
    </li>
    <li>
        <p><h5>Login to the AWS ECR registry</h5>
        <p><code>aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $account_id.dkr.ecr.$region.amazonaws.com</code>
    </li>
    <li>
        <p><h5>Manually build docker image</h5>
        <p><code>docker build -t $account_id.dkr.ecr.$region.amazonaws.com/$repo_name:$tag .</code>
    </li>
    <li>
        <p><h5>Manually push new images to the ECR registry</h5>
        <p><code>docker push $account_id.dkr.ecr.$region.amazonaws.com/$repo_name:$tag</code>
    </li>
</ul>
