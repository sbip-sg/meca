from middleware.credential_authentication import CredentialAuthenticationMiddleware
import main
from services.assignment_service import AssignmentService
from services.registration_service import RegistrationService
from services.monitoring_service import MonitoringService

def get_credential_authentication_middleware() -> CredentialAuthenticationMiddleware:
    return main.ca_middleware

def get_assignment_service() -> AssignmentService:
    return main.assignment_service

def get_registration_service() -> RegistrationService:
    return main.registration_service

def get_monitoring_service() -> MonitoringService:
    return main.monitoring_service