# chef_cfn-cookbook

TODO: Enter the cookbook description here.

## Supported Platforms

TODO: List your supported platforms.

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['chef_cfn']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### chef_cfn::default

Include `chef_cfn` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[chef_cfn::default]"
  ]
}
```

## License and Authors

Author:: Lightspeed (<jonathan@lightspeedpos.com>)
