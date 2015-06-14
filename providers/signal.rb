
use_inline_resources

def why_run_supported?
  true
end

action :signal do
  new_resource = @new_resource

  ruby_block "log signal #{new_resource.name}" do
    block do
      node.run_state[:signals_sent] << new_resource.unique_id
    end
    action :nothing
  end

  http_request "send signal #{new_resource.name}" do
    url       new_resource.url
    message   JsonCompat.to_json(new_resource.message)
    headers   "Content-Type" => ""
    action    :put
    notifies  :run, "ruby_block[#{new_resource.name}]", :immediately
  end
end

