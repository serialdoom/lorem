# lorem

Create a webserver that displays some `lorem ipsum` and a cat.

## Usage

`ansible-galaxy install lorem`

## Testing

### Vagrant testing

To test the ansible role local, spin up a vagrant box with

```
make up provision
```

This will build a box and apply this role.

NB: No port-forwarding is done, to test the vagrant box you'll need to ssh
into it (`vagrant ssh`) and then `curl http://localhost`

### Spining up an aws environment

Create an ami with

```
make packer
```

and note the ami that is returned, for example `ami-818597e5` in the log bellow

```
==> amazon-ebs: Creating snapshot tags
==> amazon-ebs: Terminating the source AWS instance...
==> amazon-ebs: Cleaning up any extra volumes...
==> amazon-ebs: No volumes to clean up, skipping
==> amazon-ebs: Deleting temporary security group...
==> amazon-ebs: Deleting temporary keypair...
Build 'amazon-ebs' finished.

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:
eu-west-2: ami-818597e5
```

Replace the ami in the terraform `aws.tf`, for example

```
resource "aws_launch_configuration" "foobar" {
  name          = "test"
  image_id      = "ami-818597e5"
  instance_type = "t2.micro"
  security_groups = [
```

and then create the aws infrastructure with

```
make apply
```

# TODOs

There are several things to be improved in this role/terraform, here is a brain
dump in no particular order.

1. Convert `aws_autoscaling_group` to an ELB.
    1. this will allow to create a route53 alias and no one has to worry about
  external DNS setup.
    2. Dont forget to add HTTP health checks so that bad servers are replaced.
2. Add some kind of profiling and logging (ELK/prometheus/etc) that will give
more info how the server is loaded when there is a lot of traffic.
    1. Do we need a larger network image cause the traffic is huge ?
    2. Do we need a larger cpu image cause nginx is strssing out ?
3. Update the `instance_type` based on the findings above
4. Update the alarms based on the findings above
    1. Now only checking average cpu time
5. Add more ansible unit tests in `tests/main.yml`. At the moment its only
testing for port 80.
    1. Could check for content (ie `curl http://localhost -dump | grep 'lorem'`)
6. Refine the security groups, at the moment all the ports are open. From
everywhere
7. Use a packer base image that has some basic linux stuff like
    1. Automatic apt security updates
    2. Automatic user setup (via vault/github ssh keys/etc) so that other people
  have ssh access to the server
8. Create a DNS routing for the servers. Either via route53 or an external
provider
    1. If an external provider is used, `user_data` in `aws_launch_configuration`
  will need modifications to register it self
9. Pin nginx version to something known and dont use the latest that is found
in time of provisioning (ie `nginx/1.10.3`)
10. Add ci for the ansible role.
    1. Vagrant build should be enough to make sure things are up and running
    2. Build the packer image when on `master` branch and then update the
  aws infra to use the new one.
    3. Run shellchek if the ansible role gets complicated, ansible lints, and
  maybe html validation software (im not aware of any)
11. Refactor terraform stuff to make it 'includable'.
    1. this module might be needed from another internal service that lives in a
  vpc (so make the module take a vpc id as input)
        1. Testing will need change to create whatever this module needs (ie
    vpc from above)
12. Make sure state is stored in a protected s3 bucket instead of a state file
locally
13. Lock ansible version to something known like packers `min_packer_version:`
14. Lock terraform version to something known (via `required_version`)
