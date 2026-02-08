"""
Database (RDS) Infrastructure Tests
Validates RDS instances are configured correctly.
"""
import pytest
from botocore.exceptions import ClientError


@pytest.mark.infrastructure
@pytest.mark.database
@pytest.mark.integration
class TestDatabase:
    """Test suite for RDS database configurations."""

    def test_rds_instance_exists(self, rds_client, resource_prefix):
        """Verify RDS instance exists."""
        db_identifier = f"{resource_prefix}-mysql"
        
        try:
            response = rds_client.describe_db_instances(
                DBInstanceIdentifier=db_identifier
            )
            instances = response['DBInstances']
            assert len(instances) > 0, f"RDS instance {db_identifier} not found"
        except ClientError as e:
            if 'DBInstanceNotFound' in str(e):
                pytest.fail(f"RDS instance {db_identifier} does not exist")
            raise

    def test_rds_instance_available(self, rds_client, resource_prefix):
        """Verify RDS instance is in available state."""
        db_identifier = f"{resource_prefix}-mysql"
        
        response = rds_client.describe_db_instances(
            DBInstanceIdentifier=db_identifier
        )
        
        if response['DBInstances']:
            status = response['DBInstances'][0]['DBInstanceStatus']
            assert status == 'available', \
                f"RDS instance status is {status}, expected 'available'"

    def test_rds_engine_version(self, rds_client, resource_prefix):
        """Verify RDS is using MySQL 8.0."""
        db_identifier = f"{resource_prefix}-mysql"
        
        response = rds_client.describe_db_instances(
            DBInstanceIdentifier=db_identifier
        )
        
        if response['DBInstances']:
            engine = response['DBInstances'][0]['Engine']
            engine_version = response['DBInstances'][0]['EngineVersion']
            
            assert engine == 'mysql', f"Engine is {engine}, expected 'mysql'"
            assert engine_version.startswith('8.0'), \
                f"Engine version is {engine_version}, expected 8.0.x"

    def test_rds_storage_encrypted(self, rds_client, resource_prefix):
        """Verify RDS storage is encrypted."""
        db_identifier = f"{resource_prefix}-mysql"
        
        response = rds_client.describe_db_instances(
            DBInstanceIdentifier=db_identifier
        )
        
        if response['DBInstances']:
            encrypted = response['DBInstances'][0]['StorageEncrypted']
            assert encrypted is True, "RDS storage encryption is not enabled"

    def test_rds_not_publicly_accessible(self, rds_client, resource_prefix):
        """Verify RDS is not publicly accessible."""
        db_identifier = f"{resource_prefix}-mysql"
        
        response = rds_client.describe_db_instances(
            DBInstanceIdentifier=db_identifier
        )
        
        if response['DBInstances']:
            publicly_accessible = response['DBInstances'][0]['PubliclyAccessible']
            assert publicly_accessible is False, \
                "RDS instance is publicly accessible (security risk!)"

    def test_rds_backup_retention(self, rds_client, resource_prefix, environment):
        """Verify RDS has appropriate backup retention for the environment."""
        db_identifier = f"{resource_prefix}-mysql"
        
        response = rds_client.describe_db_instances(
            DBInstanceIdentifier=db_identifier
        )
        
        if response['DBInstances']:
            retention = response['DBInstances'][0]['BackupRetentionPeriod']
            # Production should have at least 7 days, dev can have 0
            if environment == 'prod':
                assert retention >= 7, \
                    f"Backup retention is {retention} days, should be >= 7 for production"
            else:
                # For dev, just verify the setting exists (0 is acceptable)
                assert retention >= 0, \
                    f"Backup retention setting is invalid: {retention}"

    def test_rds_multi_az_production(self, rds_client, resource_prefix, environment):
        """Verify RDS Multi-AZ is enabled for production."""
        if environment != 'prod':
            pytest.skip("Multi-AZ only required for production")
        
        db_identifier = f"{resource_prefix}-mysql"
        
        response = rds_client.describe_db_instances(
            DBInstanceIdentifier=db_identifier
        )
        
        if response['DBInstances']:
            multi_az = response['DBInstances'][0]['MultiAZ']
            assert multi_az is True, \
                "Multi-AZ is not enabled for production database"

    def test_rds_deletion_protection_production(self, rds_client, resource_prefix, environment):
        """Verify deletion protection is enabled for production."""
        if environment != 'prod':
            pytest.skip("Deletion protection only required for production")
        
        db_identifier = f"{resource_prefix}-mysql"
        
        response = rds_client.describe_db_instances(
            DBInstanceIdentifier=db_identifier
        )
        
        if response['DBInstances']:
            deletion_protection = response['DBInstances'][0]['DeletionProtection']
            assert deletion_protection is True, \
                "Deletion protection is not enabled for production database"

    def test_rds_in_private_subnet(self, rds_client, resource_prefix):
        """Verify RDS is deployed in a database subnet group."""
        db_identifier = f"{resource_prefix}-mysql"
        
        response = rds_client.describe_db_instances(
            DBInstanceIdentifier=db_identifier
        )
        
        if response['DBInstances']:
            subnet_group = response['DBInstances'][0].get('DBSubnetGroup', {})
            subnet_group_name = subnet_group.get('DBSubnetGroupName', '')
            
            # Should have a db subnet group configured (indicates private networking)
            assert 'db' in subnet_group_name.lower() or 'subnet' in subnet_group_name.lower(), \
                f"RDS not in database subnet group: {subnet_group_name}"
