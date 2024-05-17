

resource "aws_security_group" "task" {
  vpc_id = aws_vpc.task.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "task" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "task" {
  vpc_id            = aws_vpc.task.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
}


resource "aws_ecs_cluster" "task" {
  name = "nodejs-helloworld-cluster"
}

resource "aws_ecs_task_definition" "nodejs-helloworld" {
  family                   = "nodejs-helloworld-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name  = "nodejs-helloworld"
    image = "nodejsimg"
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
  }])
}

resource "aws_ecs_service" "nodejs-helloworld" {
  name            = "nodejs-helloworld-service"
  cluster         = aws_ecs_cluster.task.id
  task_definition = aws_ecs_task_definition.nodejs-helloworld.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.task.id]
    security_groups = [aws_security_group.task.id]
  }
}

