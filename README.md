Chef_cfn Cookbook
=================

Provide tools to aid in the integration of Chef with AWS Cloudformation.

Requirements
------------

### Cookbooks:

* chef_handler
* ohai

Attributes
----------

<table>
  <tr>
    <td>Attribute</td>
    <td>Description</td>
    <td>Default</td>
  </tr>
  <tr>
    <td><code>node['cfn']['properties']</code></td>
    <td>Cloudformation metadata properties merged with cfn hint</td>
    <td><code>{}</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['properties']['mounts']</code></td>
    <td>Provides a mechanism to ensure volumes are mounted during chef</td>
    <td><code>{}</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['stack']</code></td>
    <td>Cloudformation Stack ohai namespace</td>
    <td><code>{}</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['stack']['autoscaling_name']</code></td>
    <td>Name of the autoscaling group that spawn the instance</td>
    <td><code>ohai</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['stack']['logical_id']</code></td>
    <td>Cloudformation stack logical id</td>
    <td><code>ohai</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['stack']['stack_id']</code></td>
    <td>Cloudformation stack id</td>
    <td><code>ohai</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['stack']['stack_name']</code></td>
    <td>Cloudformation stack name</td>
    <td><code>ohai</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['tags']</code></td>
    <td>Cloudformation Tags ohai namespace, converted to snake case</td>
    <td><code>{}</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['tools']['delete_on_shutdown']</code></td>
    <td>Delete the chef node on instance shutdown</td>
    <td><code>true</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['tools']['cfn_hup']['interval']</code></td>
    <td>cfn-hup will scan for metadata changes every N seconds</td>
    <td><code>10</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['tools']['cfn_hup']['verbose']</code></td>
    <td>Should cfn-hup provide verbose output</td>
    <td><code>false</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['tools']['url']</code></td>
    <td>Tarball url for cfn-init installation</td>
    <td><code></code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['vpc']</code></td>
    <td>Cloudformation VPC ohai namespace</td>
    <td><code>{}</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['vpc']['region_id']</code></td>
    <td>Aws region the instance belongs to</td>
    <td><code>ohai</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['vpc']['subnet_id']</code></td>
    <td>Aws subnet the instance belongs to</td>
    <td><code>ohai</code></td>
  </tr>
  <tr>
    <td><code>node['cfn']['vpc']['vpc_id']</code></td>
    <td>Aws vpc the instance belongs to</td>
    <td><code>ohai</code></td>
  </tr>
</table>

Recipes
-------

### chef_cfn::default

Installs dependencies

### chef_cfn::knife

(optional) Provides a basic knife.rb

### chef_cfn::ohai

Installs the aws-sdk chef_gem as well as the ohai[cfn] plugin.
When this runs, it will populate attributes under the node['cfn'] namespace which may then be used to report signals with the signal handler.

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

### chef_cfn::handler

Installs a handler to signal cloudformation of the success or failure of the chef run. When used with either Creation or Update profiles in cloudformation, we can ensure that only nodes with valid chef runs are considered healthy.

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

### chef_cfn::mounts

Mounts cloudformation defined volumes

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

### chef_cfn::tools

Installs cloudformation cfn-init tools

### chef_cfn::shutdown

Installs a service which will delete the node

Resources
---------

### chef_cfn_signal

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

