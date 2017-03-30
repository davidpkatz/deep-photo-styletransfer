docker-machine create --driver amazonec2 \
                      --amazonec2-region us-west-1 \
                      --amazonec2-zone b \
                      --amazonec2-ami ami-a58d0dc5 \
                      --amazonec2-instance-type p2.xlarge \
                      --amazonec2-vpc-id vpc-08a5cc6d \
                      --amazonec2-access-key AKIAJ5ZY5S4FY52X56BQ \
                      --amazonec2-secret-key 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 \
                      aws01