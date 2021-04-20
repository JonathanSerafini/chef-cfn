# Install common python dependencies
#
# include_recipe 'poise-python'
python_runtime '2' do
    options get_pip_url: 'https://bootstrap.pypa.io/pip/2.7/get-pip.py',
            pip_version: false,
            setuptools_version: false,
            wheel_version: false,
            virtualenv_version: false
    get_pip_url 'https://bootstrap.pypa.io/pip/2.7/get-pip.py'
    pip_version false
    setuptools_version false
    wheel_version false
    virtualenv_version false
end

cookbook_file '/tmp/pip-20.3.4-py2.py3-none-any.whl' do
  source  'pip-20.3.4-py2.py3-none-any.whl'
  owner   'root'
  group   'root'
  mode    '0444'
  action  :create
end

python_execute '/tmp/pip-20.3.4-py2.py3-none-any.whl/pip install --no-index /tmp/pip-20.3.4-py2.py3-none-any.whl' do
    python '2'
end
