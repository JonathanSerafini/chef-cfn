
use_inline_resources

def why_run_supported?
  true
end

action :create do
  template new_resource.name do
    action :create
  end
end

action :delete do
  template new_resource.name do
    action :delete
  end
end
