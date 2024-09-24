FROM odoo:15

# Install system dependencies (if any)

# Copy requirements.txt file into the container
COPY ./requirements.txt ./requirements.txt

# RUN sudo apt-get install build-essential python3-dev python2.7-dev \
# libldap2-dev libsasl2-dev slapd ldap-utils tox \
# lcov valgrind

RUN pip install -r ./requirements.txt
RUN pip install psycopg2-binary

# Set the custom addons directory
ENV ADDONS_PATH=/mnt/extra-addons


# Copy your custom module to the specified addons directory
COPY ./custom_addons ./mnt/extra-addons

RUN chmod -R 777 ./mnt/extra-addons

# Start Odoo
CMD ["odoo", "-c", "/etc/odoo/odoo.conf"]