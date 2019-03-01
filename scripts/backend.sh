#! /bin/bash -

# Declare tput red color and reset.
declare -r red=`tput setaf 1`;
declare -r reset=`tput sgr0`;

# Update packages and their dependancies.
updatePackages() {
	echo "${red}---Updating packages---${reset}";
	sudo apt-get update && sudo apt-get install git python3 postgresql postgresql-contrib  python3-pip virtualenv -y;
}

# Clone the repo and setup files.
cloneRepo() {
	echo "${red}---Cloning files---${reset}";
	dir="StackOverflow-lite";
	# If the folder already exists cd into it and pull from develop
	if [[ -d $dir ]]; then
		cd $dir;
		git pull origin development;
	# Else clone the repo
elif [[ ! -d $dir ]]; then
		git clone https://github.com/MartinKaburu/StackOverflow-lite.git -b development && cd $dir;
	fi
}

# Setup the applications virtual environment and install requirements
setupEnv() {
	echo "${red}---Setting up Environment.---${reset}";
	# If the venv folder doesn't exists create a new virtual environment and name it venv
	if [[ ! -d venv ]]; then
		virtualenv --python=python3 venv;
	fi
	# Activate the virtual environment
	source venv/bin/activate;

  # Define environment variables
  if [[ ! -e .env ]]; then
    touch .env
    cat > .env <<EOF
    export CONTEXT=DEV
    export DATABASE_NAME=postgres
    export DATABASE_HOST=localhost
    export DATABASE_PASSWORD=''
    export DATABASE_USER=postgres
    export FLASK_APP=app
    export FLASK_ENV=development
EOF
  fi
  source .env
  # Install requirements
	echo "${red}---Installing requirements---${reset}";
	pip3 install -r requirements.txt;
}

# Create a script to start the application
createStartupApp() {
	echo "${red}---Creating Startapp---${reset}"
	sudo bash -c 'cat >/home/ubuntu/start.sh <<EOF
#! /bin/bash
file=/home/ubuntu/StackOverflow-lite;
# If run.py is not in this directory cd into stackoverflowlite
if [ ! -e run.py ]; then
	cd $file;
fi
# Pull latest changes from github, activate environment, install requirements and start app
git pull origin develop;
source venv/bin/activate;
source .env
pip3 install -r requirements.txt && gunicorn app:APP -b localhost:5000;
EOF'
}

# Create the systemd service configuration
supervisorConfig() {
	conf=/etc/systemd/system/stackoverflowlite.service
	# If the configuration file does not exist touch it
	if [ ! -e $conf ]; then
		sudo touch $conf;
	fi
	# Cat this config to the file
	sudo bash -c 'cat > /etc/systemd/system/stackoverflowlite.service <<EOF
[Unit]
Description=stackoverflowlite
[Service]
WorkingDirectory=/home/ubuntu/stackoverflowlite/
ExecStart=/home/ubuntu/start.sh
[Install]
WantedBy=multi-user.target
EOF'
}

# Start the application
startApp(){
	echo "${red}---Starting app---${reset}"
	# Make the start script executable
	sudo chmod u+x /home/ubuntu/start.sh;
	# Update systemctl, enable stackoverflowlite.service to run on boot and start the service
	sudo systemctl daemon-reload;
	sudo systemctl enable stackoverflowlite.service;
	sudo systemctl start stackoverflowlite.service;
}

main() {
	updatePackages "$@";
	cloneRepo $@"";
	setupEnv "$@";
	createStartupApp "$@";
	supervisorConfig "$@";
	startApp "$@";
}

main "$@";
