# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability, please email security@arabicwordpuzzle.com
instead of opening a public issue. We will respond within 48 hours.

## Security Measures

- All network traffic is encrypted (HTTPS/TLS)
- Firebase App Check integration (Play Integrity, App Attest, reCAPTCHA)
- Encrypted local storage for sensitive data
- Firestore security rules prevent unauthorized access
- Storage security rules restrict file access
- Cloud Functions validate all server-side operations
- No sensitive data (API keys, secrets) in client code
- All secrets via environment variables / GitHub secrets
- Rate limiting on critical endpoints
- Input validation on all user data

## Best Practices for Contributors

- Never commit secrets, API keys, or credentials
- Always validate user input
- Use parameterized queries (Firestore rules)
- Follow the principle of least privilege
- Test security-related changes thoroughly
- Report vulnerabilities privately

## Disclosure Policy

We follow responsible disclosure. We ask that you:
- Do not exploit the vulnerability beyond demonstrating it
- Give us reasonable time to fix before public disclosure
- Do not access other users' data
- Do not perform attacks that could degrade service
