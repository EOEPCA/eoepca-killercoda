
Having confirmed the correct enforcement of the authorisation policies for the Dummy Service - we can now demonstrate this in action when the service is accessed via a browser.

This will show the full OIDC authentication flow in action, including redirection to Keycloak for login, and back to the protected service.

## **Access the Open service**

Access to the [Open Dummy Service]({{TRAFFIC_HOST1_92}}) is unauthenticated, so we can simply open a browser and navigate to the service URL.

## **Access the Protected service**

Access to the [Protected Dummy Service]({{TRAFFIC_HOST1_93}}) is protected via OIDC and OPA policy enforcement.

The policy defines that only privileged users can access the service - including the user `eoepcauser`{{}}

When we navigate to the service URL, we are redirected to Keycloak to authenticate.

Login as user `eoepcauser`{{}} with password `eoepcapassword`{{}} - then access to the protected service is granted.

## **Logout of the Protected service**

Ahead of the next step, we need to logout of the protected service - via this [Logout Endpoint]({{TRAFFIC_HOST1_93}}/logout).

## **Access Denied to the Protected service**

If we instead login as user `eoepcaadmin`{{}} with password `eoepcapassword`{{}}, the policy enforcement will deny access - as this user is not defined as privileged in the policy.

Navigate to the [Protected Dummy Service]({{TRAFFIC_HOST1_93}}) URL again.

Login as user `eoepcaadmin`{{}} with password `eoepcapassword`{{}} - then access to the protected service is denied - with a `403 Forbidden`{{}} response.
