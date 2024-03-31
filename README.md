# Django 5.0.3 with PostgreSQL 16 in Docker


## Quick start

Follow these steps to set up the project locally on your machine.

### Required
- Git
- docker

### Cloning the repository

```
git clone https://github.com/ArnaudSene/python-django-postgres-docker.git
cd python-django-postgres-docker
cd backend_django
```

### Create `.env` file

1. Copy/rename the .env.sample to .env
2. Update with valid information

```
cp .env.sample .env
```

### Build & deploy

**Build and deploy**
```
docker compose up --build -d
```

**Deploy**

```
docker compose up -d
```

### Stop containers

```
docker compose down
```

> **Note**
> You have to be located in the backend_django to execute `docker compose` commands

Open `http://localhost:8000` in your browser to view the project.




---

# How to create a Django 5.0.2 with PostgreSQL 16 in Docker

## Required
- python **3.12** installed
- docker installed
- poetry installed (optional if using virtualenv)

## Stack
- python **3.12**
- Django **5.0.3**
- PostgreSQL **16.2**

## Note

**Volume in Docker**
You can use persistent data storage implemented by the container engine. See https://docs.docker.com/compose/compose-file/07-volumes/

*Exemple:*

### Volume not shared with local computer
In this config, volume is stored in docker. Even if the container is deleted, the storage is still present. The volume can be shared with another service.
```yaml
services:
  db:
    image: postgres:latest
    volumes:
        postgres_data:/var/lib/postgresql/data/

volumes:
  postgres_data:
```

You can see the Docker volumes with 
```
docker volume ls
```

You can see the detail with
```
docker volume inspect django_3_postgres_data
```

```
[
    {
        "CreatedAt": "2024-03-31T19:10:24Z",
        "Driver": "local",
        "Labels": {
            "com.docker.compose.project": "django_3",
            "com.docker.compose.version": "2.24.6",
            "com.docker.compose.volume": "postgres_data"
        },
        "Mountpoint": "/var/lib/docker/volumes/django_3_postgres_data/_data",
        "Name": "django_3_postgres_data",
        "Options": null,
        "Scope": "local"
    }
]
```

### Volume shared with local computer

You can also create and share a volume with the OS.
In this config, the folder `./postgres_data` will be created on the local computer.
```yaml
services:
  db:
    image: postgres:latest
    volumes:
        ./postgres_data:/var/lib/postgresql/data/
```

> **Note** 
> Do not forget to delete the volume if you plan to create a fresh environnment!

## Prepration

### Create a project folder
```
mkdir python-django-postgres-docker
cd python-django-postgres-docker
```

### Create and activate a virtualenv
```
python3 -m venv venv
source venv/bin/activate
```

-- OR --

### Init a poetry project

```
poetry init
poetry add django=5.0.3
```

### Create a Django project

project name = `backend_django`

- *with virtualenv activated*
```
django-admin startproject backend_django .
```

- *with poetry*

```
poetry run django-admin startproject backend_django .
```


### Dockerised Django project
Using Docker in a django project. <br>

Create a .env file by copying the .env.sample provided and run:
  
```
docker compose up --build
```

-- OR --

```
docker compose build && docker compose up
```

-- OR --

```
docker-compose -f docker-compose.yml up --build
```

- Access web page at http://localhost:8000

**8000 is the default port but be free to set another port*

## Manage Django user account

### Add new useraccount app in Django
```
docker-compose exec django python manage.py startapp useraccount
```

### Edit `useraccount/models.py`
```python
import uuid
from django.conf import settings
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, \
    UserManager
from django.db import models

class CustomUserManager(UserManager):
    """_summary_

    Args:
        UserManager (_type_): _description_
    """
    def _create_user(self, name, email, password, **extra_fields):
        """_summary_

        Args:
            name (_type_): _description_
            email (_type_): _description_
            password (_type_): _description_
        """
        if not email:
            raise ValueError("You have no specifiy a valid e-mail address!")
        
        email = self.normalize_email(email)
        user = self.model(email=email, name=name, **extra_fields)
        user.set_password(password)
        user.save(using=self.db)
        
        return user
        
    def create_user(
        self, 
        name = None, 
        email = None, 
        password = None, 
        **extra_fields
    ):
        """_summary_

        Args:
            name (_type_, optional): _description_. Defaults to None.
            email (_type_, optional): _description_. Defaults to None.
        """
        extra_fields.setdefault('is_staff', False)
        extra_fields.setdefault('is_superuser', False)
        return self._create_user(name, email, password, **extra_fields)
    
    def create_superuser(
        self, 
        name = None, 
        email = None, 
        password = None, 
        **extra_fields
    ):
        """_summary_

        Args:
            name (_type_, optional): _description_. Defaults to None.
            email (_type_, optional): _description_. Defaults to None.
            password (_type_, optional): _description_. Defaults to None.
        """
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        return self._create_user(name, email, password, **extra_fields)
        
    
class User(AbstractBaseUser, PermissionsMixin):
    """_summary_

    Args:
        AbstractBaseUser (_type_): _description_
        PermissionsMixin (_type_): _description_
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email = models.EmailField(unique=True)
    name = models.CharField(max_length=255, blank=True, null=True)
    avatar = models.ImageField(upload_to='uploads/avatars')
    
    is_active = models.BooleanField(default=True)
    is_superuser = models.BooleanField(default=False)
    is_staff = models.BooleanField(default=False)
    
    date_joined = models.DateTimeField(auto_now_add=True)
    last_login = models.DateTimeField(blank=True, null=True)
    
    objects = CustomUserManager()
    
    USERNAME_FIELD = 'email'
    EMAIL_FIELD = 'email'
    REQUIRED_FIELDS = ['name',]
    
```

### Edit `settings.py` file

**Edit INSTALLED_APPS**

In `INSTALLED_APPS` add `useraccount` as
```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    'useraccount',
]
```

**Add AUTH_USER_MODEL**

```python
AUTH_USER_MODEL = 'useraccount.User'
```

### Apply useraccount model - Django migration

**manually**

`makemigrations` will create a new file in `useraccount/migrations/0001_initial.py`
`migrate` will apply/commit the model in database 
```
python manage.py makemigrations
python manage.py migrate
```

**automatically**

To apply the new model useraccount you can restart the container
```
docker compose up
```

Output should be 
```log
django3    | Operations to perform:
django3    |   Apply all migrations: admin, auth, contenttypes, sessions, useraccount
django3    | Running migrations:
django3    |   Applying contenttypes.0001_initial... OK
django3    |   Applying contenttypes.0002_remove_content_type_name... OK
django3    |   Applying auth.0001_initial... OK
django3    |   Applying auth.0002_alter_permission_name_max_length... OK
django3    |   Applying auth.0003_alter_user_email_max_length... OK
django3    |   Applying auth.0004_alter_user_username_opts... OK
django3    |   Applying auth.0005_alter_user_last_login_null... OK
django3    |   Applying auth.0006_require_contenttypes_0002... OK
django3    |   Applying auth.0007_alter_validators_add_error_messages... OK
django3    |   Applying auth.0008_alter_user_username_max_length... OK
django3    |   Applying auth.0009_alter_user_last_name_max_length... OK
django3    |   Applying auth.0010_alter_group_name_max_length... OK
django3    |   Applying auth.0011_update_proxy_permissions... OK
django3    |   Applying auth.0012_alter_user_first_name_max_length... OK
django3    |   Applying useraccount.0001_initial... OK
django3    |   Applying admin.0001_initial... OK
django3    |   Applying admin.0002_logentry_remove_auto_add... OK
django3    |   Applying admin.0003_logentry_add_action_flag_choices... OK
django3    |   Applying sessions.0001_initial... OK
django3    | Watching for file changes with StatReloader
django3    | Performing system checks...
```






## Run tests
Run descriptive tests in the container using:
```
docker exec -it <container_name> poetry run pytest -rP -vv
```

### Access the docs on:

```
http://localhost:8000/api/v1/doc
```