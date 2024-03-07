server {
    server_name             ${CLIENT_ID}.orca-solution.com;

    client_max_body_size    0;
    gzip                    on;
    gzip_types              text/css text/plain application/javascript application/json image/png;

    # api calls
    location                /api/ {
        add_header          Cache-Control 'no-cache, no-store';

        proxy_pass          http://127.0.0.1:8080;
    }

    # html-to-pdf
    location                ~ ^/pdf(?:/(.*))?$ {
        proxy_pass          http://127.0.0.1:3000/$1$is_args$args;
    }

    # static assets
    location                / {
        add_header          Cache-Control 'public';
        add_header          Cache-Control 'must-revalidate';
        etag on;

        proxy_pass          http://127.0.0.1:8080;
    }
}
