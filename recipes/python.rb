# Install common python dependencies
#
# include_recipe 'poise-python'
python_runtime '2' do
    get_pip_url 'https://bootstrap.pypa.io/pip/2.7/get-pip.py'
    pip_version true
    setuptools_version false
    wheel_version false
    virtualenv_version false           
end
