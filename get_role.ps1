param(
  [string]$RoleArn,
  [string]$SessionName = "demo"
)

$creds = aws sts assume-role `
  --role-arn $RoleArn `
  --role-session-name $SessionName | ConvertFrom-Json

$Env:AWS_ACCESS_KEY_ID     = $creds.Credentials.AccessKeyId
$Env:AWS_SECRET_ACCESS_KEY = $creds.Credentials.SecretAccessKey
$Env:AWS_SESSION_TOKEN     = $creds.Credentials.SessionToken

Write-Host "Assumed role and environment variables set for this session."