# hadoop-docker-compose-cluster
## Quick start
`docker compose up -d`

* You need to recreate the user "hue" to hue with superuser privileges to access HDFS.
## About version
| Service | Version |
|---------|---------|
| Hadoop  | 4.4.0   |
| Spark   | 3.5.1   |
| Hive    | 4.0.0   |
| Livy    | 0.9.0   |

## UI service
| Service                   | Port    |
|---------------------------|---------|
| Hadoop                    | 9870    |
| Yarn                      | 8088    |
| Spark                     | 8080    |
| Hue                       | 8888    |
| Spark history(not tested) | 18080   |