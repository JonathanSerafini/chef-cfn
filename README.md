chef\_cfn Cookbook
=================

This cookbook provides tools which aid in the integration of Chef and AWS,
specifically with CloudFormation.

Todo
----

* This cookbook will shortly be undergoing a refactor and cleanup

Requirements
------------

### Cookbooks:

* chef\_handler
* python
* ohai

## Attributes

##### Feature Flags

The recipes included within `default.rb` my be selectively enabled by toggling
the appropriate feature flags.

<table>
  <tr>
    <td>Attribute</td>
    <td>Description</td>
    <td>Default</td>
  </tr>
  <tr>
    <td><code>node['cfn']['recipes']['awslogs']</code></td>
    <td>Install the cloudwatch logs daemon named awslogs</td>
    <td><code>false</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['recipes']['cloudinit']</code></td>
    <td>Configure a stripped down cloud-init to speed up cloud instance startup
        time</td>
    <td><code>false</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['recipes']['coudwatch']</code></td>
    <td>Install a cloudwatch event handler to report chef runs back to
        cloudwatch events.</td>
    <td><code>true</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['recipes']['handler']</code></td>
    <td>**Deprecated** Install a cfn-init chef handler which will report
        chef-run success to cloudformatin.
    <td><code>true</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['recipes']['mounts']</code></td>
    <td>Format and mount volumes based on metadata provided in cloudformation</td>
    <td><code>true</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['recipes']['ohai']</code></td>
    <td>Install an ohai plugin to fetch instance, stack and metadata from ec2.
        </td>
    <td><code>true</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['recipes']['shutdown']</code></td>
    <td>**Deprecated** Install a service which will delete the chef client and
        node on shutdown</td>
    <td><code>true</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['recipes']['tools']</code></td>
    <td>Install the cfn-init and cfn-signal tools</td>
    <td><code>true</code></td>
  </tr>
</table>

##### Ohai Attributes

<table>
  <tr>
    <td>Attribute</td>
    <td>Description</td>
    <td>Default</td>
  </tr>
  <tr>
    <td><code>node['cfn']['vpc']</code></td>
    <td>Informaiton related to the VPC</td>
    <td><code>{}</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['tags']</code></td>
    <td>Hash of the EC2 instance tags</td>
    <td><code>{}</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['stack']</code></td>
    <td>Hash of Cloudformation stack parameters</td>
    <td><code>{}</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['properties']</code></td>
    <td>Hash of arbitrary metadata provided in cloudformation</td>
    <td><code>{}</code></td>
  </tr>
</table>

Recipes
-------

### chef\_cfn::default

Installs dependencies and includes additional recipes based on *feature flags*.

### chef\_cfn::awslogs

Install and configure the cloudwatch logs service

### chef\_cfn::cloudinit

Configure cloud-init in a more stripped down ec2-specific way. This recipe is mostly of use when packaging AMIs with Packer.

### chef\_cfn::handler

Install the CFN handler to callback to cloudformation on stack updates. Although this is still here, you'd likely be better off simply calling cfn-signal directly from user-data.

### chef\_cfn::knife

(optional) Provides a basic knife.rb

### chef\_cfn::ohai

Installs the aws-sdk chef_gem as well as the ohai[cfn] plugin.
When this runs, it will populate the properties, stack, tags and vpc attribute hashes under the node['cfn'] namespace which may then be used to report signals with the signal handler.

In addition, the properties hash will be merged, and potentially overriden, by any hints set in the cfn hint.

### chef\_cfn::shutdown

Installs a service which will delete the Chef client and node when the instance shuts down. This will work _most_ but not _all_ of the time and as such has been deprecated in favor of Cloudwatch Events and Lambda.

###### Required IAM policies
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1434370036000",
            "Effect": "Allow",
            "Action": [
                "cloudformation:DescribeStackResource",
                "ec2:DescribeInstances"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```

### chef\_cfn::handler

Installs a handler to signal cloudformation of the success or failure of the chef run. When used with either Creation or Update profiles in cloudformation, we can ensure that only nodes with valid chef runs are considered healthy.

This may be disabled by setting _node.cfn.tools.signal\_cloudformation_.

###### Required IAM policies
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1434370036000",
            "Effect": "Allow",
            "Action": [
                "cloudformation:SignalResource",
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```

###### Example Cloudformation
```json
{
  "AutoScailingGroup": {
    "CreationPolicy": {
      "ResourceSignal": {
        "Count": 1,
        "Timeout": "PT10M"
      }
    },
    "UpdatePolicy": {
      "AutoScalingRollingUpdate": {
        "WaitOnResourceSignals": "true"
      }
    }
  }
}
```

### chef\_cfn::mounts

Mounts cloudformation defined volumes.

Please take note that this recipe assumes that cloudformation was responsible to creating and managing the volumes, not chef. As such, all block devices must exist prior to attempting to mount them.

###### Example Cloudformation Attributes
```json
{
  "AutoScailingGroup": {
    "Metadata": {
      "Mounts": {
        "xvdb3": {
          "mount_point": "/var/log",
          "mount_options": "",
          "filesystem": ""
        }
      }
    }
  }
}
```

### chef\_cfn::tools

Installs cloudformation cfn-init tools such as :

* cfn-init
* cfn-hup: Periodic polling of cloudformation resource metadata to determine when triggered actions should run.

### chef\_cfn::shutdown

Installs a service which will delete the node when the instance shuts down.

Resources
---------

### chef\_cfn_signal

Provides an interface to trigger cloudformation signals from within recipes. This is designed to be used with cloudformation WaitConditions.

#### Actions

* signal: Default action

#### Attribute Parameters

* *url*: Url of the resource or WaitHandler to signal
* *unique_id*: Unique id of the notification
* data:  Defaults to <code>""</code>.
* success:  Defaults to <code>true</code>.
* reason:  Defaults to <code>"Chef triggered signal from resource"</code>.
* once:  Defaults to <code>true</code>.

Ohai Plugins
------------

### CFN

Fetches instance attributes from Cloudformation:DescribeResource as well as EC2:DescribeInstances.

License and Author
------------------

Author:: Jonathan Serafini (<jonathan@serafini.ca>)

Copyright:: 2015, Jonathan Serafini

License:: Apache 2.0
