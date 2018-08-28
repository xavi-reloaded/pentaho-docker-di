# xavinguer/pentaho-di

to get Pentaho:
```
wget http://downloads.sourceforge.net/project/pentaho/Data%20Integration/7.1/pdi-ce-7.1.zip
```

## Available Apps

We can use this image to run Carte server or to execute jobs and transformations with Kitchen or Pan

### Kitchen

This image can be used to run specific transformations or jobs using Pan or Kitchen, respectively. This is useful for packaging ETL scripts as Docker images, and running these images on a schedule (e.g. using cron or Chronos).

To do this, create a Dockerfile with this image in the `FROM` command. Copy the transformation and job files into the image, along with any Kettle configurations required, and run Pan or Kitchen with the appropriate command line options.

For example, in order to run jobs and transformations from a file-based repository, the repository location first needs to be set in the file `KETTLE_HOME/.kettle/repositories.xml`. Note that the path `base_directory` must be defined in the context of the Docker image, not the host machine.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<repositories>
  <repository>
    <id>KettleFileRepository</id>
    <name>my_pdi_repo</name>
    <description>My PDI Repository</description>
    <base_directory>/pentaho-di/repo</base_directory>
    <read_only>N</read_only>
    <hides_hidden_files>N</hides_hidden_files>
  </repository>
</repositories>
```

Then, assuming the transformations and jobs are in the `hostrepo` folder on the host machine, copy them to the `base_directory` in the image, and set up `CMD` to run the default job.

```dockerfile
FROM xavinguer/pentaho-di

COPY .kettle/repositories.xml $KETTLE_HOME/.kettle/repositories.xml

COPY hostrepo/* /pentaho-di/repo/

CMD ["kitchen.sh", "-rep=my_pdi_repo",  "-dir=/",  "-job=firstjob"]
```

Once the Docker image has been built, we can run the `firstjob` job. The `--rm` option can be used to automatically remove the Docker container once the job is completed, since this is a batch command and not a long-running service.

```bash
docker build -t pdi_myrepo
run docker run --rm pdi_myrepo
```

The same image can also be used to run any arbitrary job or transformation in the repository:

```bash
run docker run --rm pdi_myrepo kitchen.sh -rep=my_pdi_repo -dir=/ -job=secondjob
run docker run --rm pdi_myrepo pan -rep=my_pdi_repo -dir=/ -trans=subtrans
```

See the [Pan](http://wiki.pentaho.com/display/EAI/Pan+User+Documentation) and [Kitchen](http://wiki.pentaho.com/display/EAI/Kitchen+User+Documentation) user documentation for their full command line reference.

### Carte

This image can be used to run Carte as a long-running service, by simply using `docker run`:

```bash
docker run -d -p=8080:8080 xavinguer/pentaho-di
```

The Carte configuration can be customised using environment variables, as described above:

```bash
docker run -d -p=8080:8080 -e CARTE_NAME=mycarte -e CARTE_USER=john -e CARTE_PASSWORD=83h7c2 xavinguer/pentaho-di
```

For more advanced Carte configuration, create a new Dockerfile and supply a custom Carte configuration file. See [Carte Configuration](http://wiki.pentaho.com/display/EAI/Carte+Configuration) for available configuration options.

```dockerfile
FROM xavinguer/pentaho-di

COPY my_carte_config.xml /my_carte_config.xml

CMD ["carte.sh", "/my_carte_config.xml"]
```


## Running Custom Scripts

This image allows for full configuration and customisation via custom scripts. For example, a script can be used to clone a Git repository containing the transformations and jobs to be run.

To use custom scripts, name them with a `.sh` extension, and copy them to the `/docker-entrypoint.d` folder. For example:

```dockerfile
FROM xavinguer/pentaho-di

COPY script1.sh /docker-entrypoint.d/
COPY script2.sh /docker-entrypoint.d/
COPY script3.sh /docker-entrypoint.d/

...
```




