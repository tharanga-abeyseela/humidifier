# Humidifier

[![Build Status](https://travis-ci.com/localytics/humidifier.svg?token=kQUiABmGkzyHdJdMnCnv&branch=master)](https://travis-ci.com/localytics/humidifier)
[![Coverage Status](https://coveralls.io/repos/github/localytics/humidifier/badge.svg?branch=master&t=52zybb)](https://coveralls.io/github/localytics/humidifier?branch=master)
[![Gem Version](http://artifactory-badge.gw.localytics.com/gem/humidifier)](https://localytics.artifactoryonline.com/localytics/webapp/#/artifacts/browse/tree/General/ruby-gems-virtual/gems)

Humidifier is a small ruby gem that allows you to build AWS CloudFormation (CFN) templates programmatically. Every CFN resource is represented as a ruby object that has accessors to read and write properties that can then be uploaded to CFN. Each resource and the stack have `to_cf` methods that allow you to quickly inspect what will be uploaded. Humidifier is tested to work with ruby 2.0 and higher.

For the full docs, go to [http://localytics.github.io/humidifier/](http://localytics.github.io/humidifier/). For local development instructions, see the [Development](http://localytics.github.io/humidifier/file.Development.html) page.

## Building stacks and resources

Stacks are represented with the `Humidifier::Stack` class. You can set any of the top-level JSON attributes through the initializer. Resources are represented by an exact mapping from `AWS` resource names to `Humidifier` resources names (e.g. `AWS::EC2::Instance` becomes `Humidifier::EC2::Instance`). Resources have accessors for each JSON attribute. Each attribute can also be set through the `initialize`, `update`, and `update_attribute` methods.

```ruby
stack = Humidifier::Stack.new(
  aws_template_format_version: '2010-09-09',
  description: 'Example stack'
)

load_balancer = Humidifier::ElasticLoadBalancing::LoadBalancer.new(
  listeners: [{ 'Port' => 80, 'Protocol' => 'http', 'InstancePort' => 80, 'InstanceProtocol' => 'http' }]
)
load_balancer.scheme = 'internal'

auto_scaling_group = Humidifier::AutoScaling::AutoScalingGroup.new(min_size: '1', max_size: '20')
auto_scaling_group.update(
  availability_zones: ['us-east-1a'],
  load_balancer_names: [Humidifier.ref('LoadBalancer')]
)

stack.add('LoadBalancer', load_balancer)
stack.add('AutoScalingGroup', auto_scaling_group)
```

## Interfacing with AWS

Once stacks have the appropriate resources, you can query AWS to handle all stack CRUD operations. The operations themselves are intuitively named (i.e. `create`, `update`, `delete`). There are also convenience methods for validating a stack body (`valid?`), checking the existance of a stack (`exists?`), and creating or updating based on existance (`deploy`). The `create`, `update`, `delete`, and `deploy` methods all have `_and_wait` corrolaries that will cause the main ruby thread to sleep until the operation is complete.

Humidifier assumes you have an `aws-sdk` gem installed when you call these operations. It detects the version of the gem you have installed and uses the appropriate API depending on what is available. If Humidifier cannot find any way to use the AWS SDK, it will warn you on every API call and simply return false.

You can use CFN intrinsic functions and references using `Humidifier.fn.[name]` and `Humidifier.ref`. Those will build appropriate structures that know how to be dumped to CFN syntax appropriately.

## Introspection

* To see the template body, you can check the `to_cf` method on stacks, resources, fns, and refs. All of them will output a hash of what will be uploaded (except the stack, which will output a string representation).
* Humidifier itself contains a registry of all possible resources that it supports. You can access it with `Humidifier.registry` which is a hash of AWS resource name pointing to the class.
* Resources have an `aws_name` method to see how AWS references them. They also contain a `props` method that contains a hash of the name that Humidifier uses to reference the prop pointing to the appropriate prop object.
