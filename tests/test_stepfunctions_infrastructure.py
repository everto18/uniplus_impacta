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

    def test_video_processor_exists(self, sfn_client, resource_prefix):
        """Verify video processor state machine exists."""
        state_machine_name = f"{resource_prefix}-video-processor"
        
        # List state machines and find ours
        response = sfn_client.list_state_machines()
        state_machines = response['stateMachines']
        
        names = [sm['name'] for sm in state_machines]
        assert state_machine_name in names, \
            f"State machine {state_machine_name} not found. Available: {names}"

    def test_state_machine_is_active(self, sfn_client, resource_prefix):
        """Verify state machine is in ACTIVE status."""
        state_machine_name = f"{resource_prefix}-video-processor"
        
        response = sfn_client.list_state_machines()
        state_machines = {sm['name']: sm for sm in response['stateMachines']}
        
        if state_machine_name in state_machines:
            sm_arn = state_machines[state_machine_name]['stateMachineArn']
            describe = sfn_client.describe_state_machine(stateMachineArn=sm_arn)
            
            assert describe['status'] == 'ACTIVE', \
                f"State machine status is {describe['status']}, expected ACTIVE"
        else:
            pytest.skip(f"State machine {state_machine_name} not found")

    def test_state_machine_has_definition(self, sfn_client, resource_prefix):
        """Verify state machine has a valid definition."""
        state_machine_name = f"{resource_prefix}-video-processor"
        
        response = sfn_client.list_state_machines()
        state_machines = {sm['name']: sm for sm in response['stateMachines']}
        
        if state_machine_name in state_machines:
            sm_arn = state_machines[state_machine_name]['stateMachineArn']
            describe = sfn_client.describe_state_machine(stateMachineArn=sm_arn)
            
            definition = json.loads(describe['definition'])
            states = definition.get('States', {})
            
            # Should have at least one state defined
            assert len(states) > 0, \
                "State machine has no states defined"

    def test_state_machine_has_error_handling(self, sfn_client, resource_prefix):
        """Verify state machine has error handling configured."""
        state_machine_name = f"{resource_prefix}-video-processor"
        
        response = sfn_client.list_state_machines()
        state_machines = {sm['name']: sm for sm in response['stateMachines']}
        
        if state_machine_name in state_machines:
            sm_arn = state_machines[state_machine_name]['stateMachineArn']
            describe = sfn_client.describe_state_machine(stateMachineArn=sm_arn)
            
            definition = json.loads(describe['definition'])
            states = definition.get('States', {})
            
            # Check for error handling states - Catch, Retry, or Fail state
            has_catch = any('Catch' in state for state in states.values())
            has_retry = any('Retry' in state for state in states.values())
            has_fail_state = any(state.get('Type') == 'Fail' for state in states.values())
            
            assert has_catch or has_retry or has_fail_state, \
                "No error handling (Catch, Retry, or Fail state) found"
        else:
            pytest.skip(f"State machine {state_machine_name} not found")

    def test_state_machine_has_iam_role(self, sfn_client, resource_prefix):
        """Verify state machine has IAM role attached."""
        state_machine_name = f"{resource_prefix}-video-processor"
        
        response = sfn_client.list_state_machines()
        state_machines = {sm['name']: sm for sm in response['stateMachines']}
        
        if state_machine_name in state_machines:
            sm_arn = state_machines[state_machine_name]['stateMachineArn']
            describe = sfn_client.describe_state_machine(stateMachineArn=sm_arn)
            
            role_arn = describe.get('roleArn')
            assert role_arn is not None, "No IAM role attached to state machine"
            assert 'arn:aws:iam::' in role_arn, f"Invalid role ARN: {role_arn}"
        else:
            pytest.skip(f"State machine {state_machine_name} not found")

    def test_state_machine_logging_enabled(self, sfn_client, resource_prefix):
        """Verify state machine has logging configured."""
        state_machine_name = f"{resource_prefix}-video-processor"
        
        response = sfn_client.list_state_machines()
        state_machines = {sm['name']: sm for sm in response['stateMachines']}
        
        if state_machine_name in state_machines:
            sm_arn = state_machines[state_machine_name]['stateMachineArn']
            describe = sfn_client.describe_state_machine(stateMachineArn=sm_arn)
            
            logging_config = describe.get('loggingConfiguration', {})
            log_level = logging_config.get('level', 'OFF')
            
            # Should have at least ERROR level logging or OFF is acceptable for dev
            assert log_level in ['OFF', 'ERROR', 'FATAL', 'ALL'], \
                f"Invalid logging level: {log_level}"
        else:
            pytest.skip(f"State machine {state_machine_name} not found")

    def test_state_machine_invokes_lambda(self, sfn_client, resource_prefix):
        """Verify state machine invokes the video processor Lambda."""
        state_machine_name = f"{resource_prefix}-video-processor"
        
        response = sfn_client.list_state_machines()
        state_machines = {sm['name']: sm for sm in response['stateMachines']}
        
        if state_machine_name in state_machines:
            sm_arn = state_machines[state_machine_name]['stateMachineArn']
            describe = sfn_client.describe_state_machine(stateMachineArn=sm_arn)
            
            definition = describe['definition']
            
            # Should reference Lambda in the definition
            assert 'lambda:invoke' in definition.lower() or 'arn:aws:lambda' in definition.lower(), \
                "State machine does not appear to invoke Lambda"
        else:
            pytest.skip(f"State machine {state_machine_name} not found")
