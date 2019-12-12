# API Specifications

## Models

### ApiToken

```jsonc
{
  "identity": {},  //UserIdentity object
  "application": {},  // Application object
  "accessKey": "string",
  "secretKey": "string",
  "expireAt": "datetime",
}
```

### Application

```jsonc
{
  "uuid": "string",
  "name": "string"
}
```

### AppAuthorization

```jsonc
{
  "app": {},  // Application object
  "userIdentity": {}  // UserIdentity object
}
```

### UserIdentity

```jsonc
{
  "uuid": "string",
  "username": "string"
}
```

### UserAccount

```jsonc
{
  "identity": {},  // UserIdentity object
  "provider": "string",  // "google"
  "providerId": "string"
}
```

## APIs

- POST /v1/accounts/google
- POST /v1/api_tokens/google
- GET /v1/applications
- POST /v1/applications
- POST /v1/applications/authorization
- GET /v1/identities/me

### POST /v1/accounts/google

* Request Body
    ```jsonc
    {
      "username": "string",
      "idToken": "string"
    }
    ```
* Returns
    * 201 Created
    * 400 Bad Request (duplicated_account)
    * 400 Bad Request (invalid_provider_id)

### POST /v1/api_tokens/google

* Request Body
    ```jsonc
    {
      "appId": "string",
      "idToken": "string"
    }
    ```
* Returns
    * 201 Created
    * 400 Bad Request (unauthorized_application)
    * 401 Unauthorized

### GET /v1/applications

* Query Parameters
    * `ownerId` (string?)
* Returns
    * 200 OK

### POST /v1/applications

Authentication required.

* Request Body
    ```jsonc
    {
      "name": "string",
      "redirectUrl": "string?"
    }
    ```
* Returns
    * 201 Created
    * 400 Bad Request (duplicated_names)

### POST /v1/applications/authorizations

Authentication required.

* Request Body
    ```jsonc
    {
      "appId": "string"
    }
    ```
* Returns
    * 200 OK

### GET /v1/identities/me

Authentication required.

* Returns
    * 200 OK
    * 401 Unauthorized
