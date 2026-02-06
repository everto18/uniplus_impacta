"""
Networking Infrastructure Tests
Validates VPC, subnets, and security groups.
"""
import pytest
from botocore.exceptions import ClientError


@pytest.mark.infrastructure
@pytest.mark.networking
@pytest.mark.integration
class TestNetworking:
    """Test suite for networking configurations."""

    def test_vpc_exists(self, ec2_client, resource_prefix):
        """Verify VPC exists."""
        response = ec2_client.describe_vpcs(
            Filters=[
                {'Name': 'tag:Name', 'Values': [f"{resource_prefix}-vpc"]}
            ]
        )
        
        vpcs = response['Vpcs']
        assert len(vpcs) > 0, f"VPC {resource_prefix}-vpc not found"

    def test_vpc_cidr_block(self, ec2_client, resource_prefix, environment):
        """Verify VPC has correct CIDR block."""
        response = ec2_client.describe_vpcs(
            Filters=[
                {'Name': 'tag:Name', 'Values': [f"{resource_prefix}-vpc"]}
            ]
        )
        
        if response['Vpcs']:
            vpc = response['Vpcs'][0]
            cidr = vpc['CidrBlock']
            
            # Dev should be 10.0.0.0/16, prod should be 10.1.0.0/16
            expected_cidrs = {
                'dev': '10.0.0.0/16',
                'prod': '10.1.0.0/16'
            }
            
            if environment in expected_cidrs:
                assert cidr == expected_cidrs[environment], \
                    f"VPC CIDR is {cidr}, expected {expected_cidrs[environment]}"

    def test_public_subnets_exist(self, ec2_client, resource_prefix):
        """Verify public subnets exist."""
        response = ec2_client.describe_subnets(
            Filters=[
                {'Name': 'tag:Name', 'Values': [f"{resource_prefix}-public-*"]}
            ]
        )
        
        subnets = response['Subnets']
        assert len(subnets) >= 2, \
            f"Expected at least 2 public subnets, found {len(subnets)}"

    def test_private_app_subnets_exist(self, ec2_client, resource_prefix):
        """Verify private app subnets exist."""
        response = ec2_client.describe_subnets(
            Filters=[
                {'Name': 'tag:Name', 'Values': [f"{resource_prefix}-private-app-*"]}
            ]
        )
        
        subnets = response['Subnets']
        assert len(subnets) >= 2, \
            f"Expected at least 2 private app subnets, found {len(subnets)}"

    def test_private_data_subnets_exist(self, ec2_client, resource_prefix):
        """Verify private data subnets exist."""
        response = ec2_client.describe_subnets(
            Filters=[
                {'Name': 'tag:Name', 'Values': [f"{resource_prefix}-private-data-*"]}
            ]
        )
        
        subnets = response['Subnets']
        assert len(subnets) >= 2, \
            f"Expected at least 2 private data subnets, found {len(subnets)}"

    def test_nat_gateway_exists(self, ec2_client, resource_prefix):
        """Verify NAT Gateway exists."""
        response = ec2_client.describe_nat_gateways(
            Filters=[
                {'Name': 'tag:Name', 'Values': [f"{resource_prefix}-nat-*"]},
                {'Name': 'state', 'Values': ['available']}
            ]
        )
        
        nat_gateways = response['NatGateways']
        assert len(nat_gateways) >= 1, \
            f"No NAT Gateway found for {resource_prefix}"

    def test_internet_gateway_attached(self, ec2_client, resource_prefix):
        """Verify Internet Gateway is attached to VPC."""
        # First get VPC
        vpc_response = ec2_client.describe_vpcs(
            Filters=[
                {'Name': 'tag:Name', 'Values': [f"{resource_prefix}-vpc"]}
            ]
        )
        
        if vpc_response['Vpcs']:
            vpc_id = vpc_response['Vpcs'][0]['VpcId']
            
            igw_response = ec2_client.describe_internet_gateways(
                Filters=[
                    {'Name': 'attachment.vpc-id', 'Values': [vpc_id]}
                ]
            )
            
            igws = igw_response['InternetGateways']
            assert len(igws) > 0, \
                f"No Internet Gateway attached to VPC {vpc_id}"

    def test_alb_security_group_exists(self, ec2_client, resource_prefix):
        """Verify ALB security group exists."""
        response = ec2_client.describe_security_groups(
            Filters=[
                {'Name': 'tag:Name', 'Values': [f"{resource_prefix}-alb-sg"]}
            ]
        )
        
        sgs = response['SecurityGroups']
        assert len(sgs) > 0, f"ALB security group not found"

    def test_ecs_security_group_exists(self, ec2_client, resource_prefix):
        """Verify ECS security group exists."""
        response = ec2_client.describe_security_groups(
            Filters=[
                {'Name': 'tag:Name', 'Values': [f"{resource_prefix}-ecs-tasks-sg"]}
            ]
        )
        
        sgs = response['SecurityGroups']
        assert len(sgs) > 0, f"ECS security group not found"

    def test_rds_security_group_exists(self, ec2_client, resource_prefix):
        """Verify RDS security group exists."""
        response = ec2_client.describe_security_groups(
            Filters=[
                {'Name': 'tag:Name', 'Values': [f"{resource_prefix}-rds-sg"]}
            ]
        )
        
        sgs = response['SecurityGroups']
        assert len(sgs) > 0, f"RDS security group not found"
