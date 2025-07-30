# Security Guidelines

Security best practices and guidelines for the ReinventingAI infrastructure repository.

## Secrets Management

**Environment Variables**
- All sensitive configuration is stored in `.env` files
- `.env` files are **never** committed to version control
- Use `.env.example` as template with placeholder values
- Generate unique encryption keys for each environment: `openssl rand -hex 32`

**What to Keep Secret**
- N8N_ENCRYPTION_KEY (64-character encryption key)
- API keys and tokens
- Database credentials
- SSL certificates and private keys
- OAuth client secrets

## Repository Security

**Protected Files**
The following files are automatically ignored by Git:
- `.env` (and all variants)
- `*.key`, `*.pem`, `*.crt` (certificates and keys)
- `secrets/`, `credentials/`, `private/` (sensitive directories)
- `*.tar.gz`, `*.backup` (backup files that may contain data)

**Security Scanning**
Run security checks before committing:
```bash
# Check for accidentally exposed secrets
git diff --cached | grep -E "(password|secret|key|token|api_key)"

# Verify .env is not tracked
git status --ignored | grep .env

# Run documentation tests (includes security checks)
./scripts/test-documentation.sh
```

## Docker Security

**Container Security**
- Containers run as non-root user where possible
- External volumes are used for data persistence
- Health checks are enabled for service monitoring
- Network exposure is limited to necessary ports only

**Image Security**
- Use specific image versions, not `latest` tags
- Images are pulled from official repositories
- Regular updates to address security vulnerabilities

## Access Control

**Repository Access**
- Private repository with controlled access
- Team members must have legitimate business need
- Regular review of repository access permissions

**Service Access**
- n8n service accessible only through Cloudflare tunnel
- No direct port exposure to internet
- SSL/TLS encryption for all connections

## Infrastructure Security

**Network Security**
- Services accessible only through secure tunnels
- SSL certificates managed by Cloudflare
- No credentials transmitted in plain text

**Backup Security**
- Backups contain encrypted n8n data
- Backup files are excluded from version control
- Regular backup integrity verification

## Security Incident Response

**If Credentials Are Compromised**
1. Immediately revoke/rotate the compromised credentials
2. Generate new encryption keys: `openssl rand -hex 32`
3. Update `.env` files with new values
4. Restart affected services
5. Review access logs for unauthorized activity
6. Document incident and remediation steps

**If Repository is Compromised**
1. Immediately change all credentials referenced in the repository
2. Review commit history for any accidentally exposed secrets
3. Rotate all encryption keys and API tokens
4. Audit team access to repository
5. Consider repository access log review

## Compliance Checklist

**Before Each Release**
- [ ] Run `./scripts/test-documentation.sh`
- [ ] Verify no secrets in commit diff
- [ ] Check `.env` files are properly ignored
- [ ] Confirm all credentials use placeholder values in examples
- [ ] Validate backup procedures work correctly

**Monthly Security Review**
- [ ] Review repository access permissions
- [ ] Rotate encryption keys if needed
- [ ] Test disaster recovery procedures
- [ ] Update dependencies for security patches
- [ ] Review and update this security documentation

## Reporting Security Issues

Security issues should be reported privately to repository maintainers. Do not create public issues for security vulnerabilities.

## Security Resources

- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Git Security Best Practices](https://github.com/OWASP/CheatSheetSeries/blob/master/cheatsheets/Git_Secrets_Cheat_Sheet.md)
- [Environment Variable Security](https://blog.gitguardian.com/secrets-api-management/)