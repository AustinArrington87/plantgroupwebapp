# plantgroupwebapp
Django web app for PLANT GROUP, LLC

Dev environment
Run docker-compose up or docker-compose up -d && docker-compose logs -f. The first time you run it, it will build the containers which will take a while. After that, it will be quicker.

When it's running, do docker ps. You should see 3 containers running: django, postgres, and webpack. Note the container ID for the django container.

Run docker exec -it {DJANGO_CONTAINER_ID} bash to get a shell into the container running Django

In the shell do the following to set up the database and bootstrap the system with a superuser

pym migrate
pym createsuperuser
It will ask you for email and password for the superuser. After this succeeds you can go to http://localhost:8888 and log in with the credentials you just entered.

AWS DevOps setup
First of all, get access keys for IAM user with appropriate permissions (Full Admin permissions to be safe)
Add these keys to ~/.aws/credentials under a profile named [plantgroup]. (The name plantgroup is hard-coded in various scripts)

SES
Set up SES user.

RDS (database)
Go to RDS. Launch instance Postgres 9.6.6 t2.micro, dev/test is fine for now * publicly available

Set django/secrets/secrets.production.yml with the proper database credentials as created during this setup process

If needed, dump and restore old database to new, e.g.:

pg_dump -h plant-db-beta.cnmaldy9blta.us-west-2.rds.amazonaws.com -U plantgroup_webapp_db -d plantgroup_webapp_db -F c > dump.sql
pg_restore -h pg-webapp-db.ciayxuc8fed7.us-east-1.rds.amazonaws.com -U plantgroup_webapp_db -d plantgroup_webapp_db --no-owner dump.sql
EC2 Instance setup
Create it using docker-machine:

Make sure bin/doma-create has SAME VPC and availability zone as the RDS instance previously created
AWS_PROFILE=plantgroup bin/doma-create
Set up security group with the following Inbound TCP ports open: - 80 (http) - 8000 (django) - 5432 (postgres)

Deployment
Here's what you do each time you want to deploy, and also some tips:

source bin/deploy-mode.sh
doco-deploy
That will rebuild all the new code and push it up to the EC2 instance, restart server, etc.

To get a shell into the running Django instance:

cd django
docker ps  # to find out the container id
docker exec -i <CONTAINER_ID> bash  # use container id found in previous command
