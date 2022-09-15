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

<p>The solution chosen to deploy the application uses EKS as environment and Terraform for its deployment.

## Table of Contents  
1) [Vagrant environment](#vagrant)

    1.1) [Installation](#vagrant1-1)

    1.2) [Environment provisioning](#vagrant-1-2)

    1.3) [Accessing environment](#vagrant-1-3)

    1.4) [Clean up](#vagrant-1-4)

2) [Title2](#link2)

    2.1) [Title2.sub1](#link2-1)

    2.2) [Title2.sub2](#link2-2)


<a name="vagrant">

## 1. Vagrant environment


<p><a href="https://www.vagrantup.com/" target="_blank">Vagrant</a> is a tool used to provision virtual environments. It is useful to provide developers with an easily reproducible environment with all the required tools to develop and build the project. The state of the project directory in the virtual environment is synchronized with that of the host to preserve changes without any further action.


<a name="vagrant1-1">

#### Installation

<p>Please refer to the <a href="https://www.vagrantup.com/downloads" target="_blank">download page</a> to install vagrant on your system. Version used was <code>2.2.18</code>.


<a name="vagrant1-2">

#### Environment provisioning

<p>To create a new Vagrant machine enter the <code>./vagrant</code> directory and lunch <code>vagrant up</code>. The whole process might take a few minutes the first time as Vagrant downloads box image. In case the machine was already created it is possible to re run the provisioning process by adding the <code>--provision</code> flag.


<a name="vagrant1-3">

#### Accessing provisioned environment

<p>Once created we can access the virtual machine using <code>vagrant ssh</code>. This will establish a new ssh session with the guest host.


<a name="vagrant1-4">

#### Clean up

<p>To suspend the environment run <code>vagrant suspend</code>, this will hibernate the guest machine while preserving its RAM. To shut down completely use <code>vagrant halt</code>. Use <code>vagrant destroy</code> to stop and remove all traces of the guest host.
