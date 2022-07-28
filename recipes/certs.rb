execute "install latest certs" do
    command "curl -k https://curl.se/ca/cacert-2022-07-19.pem -o /etc/ssl/certs/ca-certificates.crt ;
        cp /etc/ssl/certs/ca-certificates.crt /opt/chef/embedded/ssl/certs/cacert.pem ;
        cp /etc/ssl/certs/ca-certificates.crt /usr/lib/ssl/cert.pem"
end
