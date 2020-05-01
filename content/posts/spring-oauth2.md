---
title: "Spring OpenID Connect 请求过程"
date: 2021-11-10T09:05:00+08:00
tags: ["oauth2"]
categories: [""]
draft: true
---

```java
ProviderSettings

.authorizationEndpoint("/oauth2/authorize")
.tokenEndpoint("/oauth2/token")
.jwkSetEndpoint("/oauth2/jwks")
.tokenRevocationEndpoint("/oauth2/revoke")
.tokenIntrospectionEndpoint("/oauth2/introspect")
.oidcClientRegistrationEndpoint("/connect/register");
```

| endpoint                                  | note |
|-------------------------------------------|------|
| `/oauth2/authorize`                       |      |
| `/oauth2/token`                           |      |
| `/oauth2/jwks`                            |      |
| `/oauth2/revoke`                          |      |
| `/oauth2/introspect`                      |      |
| `/connect/register`                       |      |
| `/.well-known/oauth-authorization-server` |      |

- GET <http://127.0.0.1:9000/.well-known/oauth-authorization-server>
- GET <http://127.0.0.1:9000/oauth2/jwks>

### token class

```java
class OAuth2AuthorizationCode {
    String tokenValue;
    Instant issuedAt;
    Instant expiresAt;
}

class OAuth2AccessToken {
    String tokenValue;
    Instant issuedAt;
    Instant expiresAt;

    TokenType tokenType;
    Set<String> scopes;
}

class OAuth2RefreshTokeh {
    String tokenValue;
    Instant issuedAt;
    Instant expiresAt;
}

class OidcIdToken {
    String tokenValue;
    Instant issuedAt;
    Instant expiresAt;
    
    Map<String, Object> claims;
}
```
    
oauth2_authorization

### wireshark

