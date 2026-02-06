"""
Step Functions Infrastructure Tests
Validates Step Functions state machine is configured correctly.
"""
import json
import pytest
from botocore.exceptions import ClientError


@pytest.mark.infrastructure
@pytest.mark.stepfunctions
@pytest.mark.integration
class TestStepFunctions:
    """Test suite for Step Functions configurations."""

    def test_video_batch_processor_exists(self, sfn_client, resource_prefix):
        """Verify video batch processor state machine exists."""
        state_machine_name = f"{resource_prefix}-video-batch-processor"
        
        # List state machines and find ours
        response = sfn_client.list_state_machines()
        state_machines = response['stateMachines']
        
        names = [sm['name'] for sm in state_machines]
        assert state_machine_name in names, \
            f"State machine {state_machine_name} not found. Available: {names}"

    def test_state_machine_is_active(self, sfn_client, resource_prefix):
        """Verify state machine is in ACTIVE status."""
        state_machine_name = f"{resource_prefix}-video-batch-processor"
        
        response = sfn_client.list_state_machines()
        state_machines = {sm['name']: sm for sm in response['stateMachines']}
        
        if state_machine_name in state_machines:
            sm_arn = state_machines[state_machine_name]['stateMachineArn']
            describe = sfn_client.describe_state_machine(stateMachineArn=sm_arn)
            
            assert describe['status'] == 'ACTIVE', \
                f"State machine status is {describe['status']}, expected ACTIVE"

    def test_state_machine_has_map_state(self, sfn_client, resource_prefix):
        """Verify state machine has Map state for parallel processing."""
        state_machine_name = f"{resource_prefix}-video-batch-processor"
        
        response = sfn_client.list_state_machines()
        state_machines = {sm['name']: sm for sm in response['stateMachines']}
        
        if state_machine_name in state_machines:
            sm_arn = state_machines[state_machine_name]['stateMachineArn']
            describe = sfn_client.describe_state_machine(stateMachineArn=sm_arn)
            
            definition = json.loads(describe['definition'])
            states = definition.get('States', {})
            
            # Check for Map state
            map_states = [name for name, state in states.items() 
                         if state.get('Type') == 'Map']
            
            assert len(map_states) > 0, \
                "No Map state found in state machine definition"

    def test_state_machine_max_concurrency(self, sfn_client, resource_prefix):
        """Verify Map state has MaxConcurrency set to 5."""
        state_machine_name = f"{resource_prefix}-video-batch-processor"
        
        response = sfn_client.list_state_machines()
        state_machines = {sm['name']: sm for sm in response['stateMachines']}
        
        if state_machine_name in state_machines:
            sm_arn = state_machines[state_machine_name]['stateMachineArn']
            describe = sfn_client.describe_state_machine(stateMachineArn=sm_arn)
            
            definition = json.loads(describe['definition'])
            states = definition.get('States', {})
            
            # Find Map state and check MaxConcurrency
            for name, state in states.items():
                if state.get('Type') == 'Map':
                    max_concurrency = state.get('MaxConcurrency', 0)
                    assert max_concurrency == 5, \
                        f"MaxConcurrency is {max_concurrency}, expected 5"
                    return
            
            pytest.fail("No Map state found to verify MaxConcurrency")

    def test_state_machine_has_error_handling(self, sfn_client, resource_prefix):
        """Verify state machine has error handling configured."""
        state_machine_name = f"{resource_prefix}-video-batch-processor"
        
        response = sfn_client.list_state_machines()
        state_machines = {sm['name']: sm for sm in response['stateMachines']}
        
        if state_machine_name in state_machines:
            sm_arn = state_machines[state_machine_name]['stateMachineArn']
            describe = sfn_client.describe_state_machine(stateMachineArn=sm_arn)
            
            definition = json.loads(describe['definition'])
            states = definition.get('States', {})
            
            # Check for error handling states
            has_catch = any('Catch' in state for state in states.values())
            has_fail_state = any(state.get('Type') == 'Fail' for state in states.values())
            
            assert has_catch or has_fail_state, \
                "No error handling (Catch or Fail state) found"

    def test_state_machine_has_iam_role(self, sfn_client, resource_prefix):
        """Verify state machine has IAM role attached."""
        state_machine_name = f"{resource_prefix}-video-batch-processor"
        
        response = sfn_client.list_state_machines()
        state_machines = {sm['name']: sm for sm in response['stateMachines']}
        
        if state_machine_name in state_machines:
            sm_arn = state_machines[state_machine_name]['stateMachineArn']
            describe = sfn_client.describe_state_machine(stateMachineArn=sm_arn)
            
            role_arn = describe.get('roleArn')
            assert role_arn is not None, "No IAM role attached to state machine"
            assert 'arn:aws:iam::' in role_arn, f"Invalid role ARN: {role_arn}"

    def test_state_machine_logging_enabled(self, sfn_client, resource_prefix):
        """Verify state machine has logging configured."""
        state_machine_name = f"{resource_prefix}-video-batch-processor"
        
        response = sfn_client.list_state_machines()
        state_machines = {sm['name']: sm for sm in response['stateMachines']}
        
        if state_machine_name in state_machines:
            sm_arn = state_machines[state_machine_name]['stateMachineArn']
            describe = sfn_client.describe_state_machine(stateMachineArn=sm_arn)
            
            logging_config = describe.get('loggingConfiguration', {})
            log_level = logging_config.get('level', 'OFF')
            
            # Should have at least ERROR level logging
            assert log_level in ['ERROR', 'FATAL', 'ALL'], \
                f"Logging level is {log_level}, should be ERROR or higher"
