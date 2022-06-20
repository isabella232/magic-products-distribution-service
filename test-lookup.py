import requests
from requests_auth_aws_sigv4 import AWSSigV4

lookup_item = {
    'artefact_id': '398be6d5-b411-4960-aad9-e091d87114c1',
    'resource_id': '24dce09c-9eee-4d90-8402-63f63012d767',
    'media_type': 'application/pdf',
    'origin_uri': 'https://nercacuk.sharepoint.com/sites/MAGICProductsDistribution/Main/24dce09c-9eee-4d90-8402-63f63012d767/foo-map.pdf'
}

lambda_endpoint = 'https://zrpqdlufnfqcmqmzppwzegosvu0rvbca.lambda-url.eu-west-1.on.aws/'


if __name__ == "__main__":
    deposit_request = requests.post(url=lambda_endpoint, json=lookup_item, auth=AWSSigV4('lambda'))
    deposit_request.raise_for_status()
    print(deposit_request.status_code)
