# MAGIC Products Distribution

Service for distributing products produced or managed by the Mapping and Geographic Information Centre (MAGIC) at the
British Antarctic Survey (BAS).

## Overview

### Purpose

... acts as a data access system only, Data Catalogue used as a frontend with HTTP/URLs used as an interface. ...

### Status

This project is an early alpha. This means:

* all, or parts, of this service may not be working
* all, or parts, of this service may stop working at any time
* all, or parts, of this service may not work correctly, or as expectedly (including destructively)
* all, or parts, of this service may change at any time (in terms of implementation or functionally)
* documentation may be missing or incorrect
* no support is provided

### Scope

#### Products

This service SHOULD be used for distributing products created or managed by MAGIC. This service MUST NOT be used for
distributing any datasets.

Products are considered to be:

* ...

Datasets are considered to be:

* ...

**Note:** These lists are not exhaustive. It is accepted these definitions are imperfect and subjective. Specific use
cases can be discussed as needed (using the *#data* channel in Slack initially).

Products and datasets are treated differently for practical and organisational reasons (datasets are considerably
bigger in storage/quantity volume than products, and BAS datasets are managed by the Polar Data Centre). As such,
unrestricted datasets MUST be deposited with the PDC. Use cases for distributing restricted datasets SHOULD be discussed
internally (using the *#data* channel in Slack initially) to find a suitable solution.

#### Access only

... this service is read-only. It is not designed to allow end-users to deposit products themselves. ...

#### File sizes

As soft limits:

* the total size of artefacts for each product/resource SHOULD NOT exceed 3GB (giving roughly 8,500 deposits)

**Note:** It is fine for some products to exceed this limit, as its assumed most products will be significantly smaller
than this limit.

As hard limits, the
[SharePoint service limits](https://docs.microsoft.com/en-us/office365/servicedescriptions/sharepoint-online-service-description/sharepoint-online-limits)
apply. Namely:

* any file MUST NOT exceed 250GB
* the total, maximum, size of all files MUST NOT exceed 25TB
* the maximum number of items (files/folders) MUST NOT exceed 30 million

#### Personal data

Products containing routine personal data, such as the author of a map, MAY be deposited in this service without
discussion, including as unrestricted products.

Products relating to individuals (where they can be identified) MAY be deposited in this service, providing they are
restricted. Making such products unrestricted MUST be discussed beforehand.

Products containing
[sensitive personal/category data](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/lawful-basis-for-processing/special-category-data/#scd1)
(such as health, ethnicity or religious data) MUST be discussed before being deposited in this service.

## Usage

### Test upload script

A test script is available to check test files can be uploaded and permissions set correctly etc. This script can be
ran within a [Development Environment](#development-environment).

```shell
$ poetry run python test-upload.py
```

**Note:** You will be asked to sign-in to the 'MAGIC-PDC Data Workflows PoC' application when completing the OAuth login
process. This is temporary until dedicated Azure App Registration is made for this service.

**Note:** This test script will be wholly replaced with a proper application once we've verified SharePoint works as
expected. As such, this code is not well written, structured, or tested.

### Manually depositing artefacts

**Note:** These instructions should only be used as a last resort, where automated methods have failed and the need is
urgent.

**Note:** You need suitable permissions (being a member of MAGIC) to perform these instructions.

1. from the [MAGIC Products Distribution](https://nercacuk.sharepoint.com/sites/MAGICProductsDistribution/_layouts/15/viewlsts.aspx?view=14)
   SharePoint site, select the relevant document library (use 'Main' if unsure)
2. click *+ New* -> *Folder* from the toolbar
  * name the folder after the ID of the metadata record the artefacts relate to
3. click *Edit in grid view* from the toolbar
  * fill in the 'Record ID' value for the new folder, using the ID of the metadata record the artefacts relate to
  * click *Exit grid view* from the toolbar
4. navigate into the newly created folder
5. upload the artefacts (either using the *Upload* option in the toolbar or by dragging & dropping into the main window)
6. click *Edit in grid view* from the toolbar
  * fill in the 'Record ID' value for each uploaded artefact, using the ID of the metadata record they relate to
  * click *Exit grid view* from the toolbar

... permissions ...

... distribution option in records ...

## Implementation

### SharePoint - structure

TODO: Split out conceptual model from SharePoint model as sections, re-orientate sections to not be SharePoint centric.

SharePoint is used to store, and manage access to, product artefacts distributed through this service.

Conceptually, Artefacts (files) for Resources (products) are stored as objects, with tags storing unique identifiers for
each Artefact and the Resource they relate to.

Within SharePoint, artefacts are stored as files in a SharePoint document library. Files are grouped into directories
named resource they relate to. Two custom columns (`resource_id` and `artefact_id`), in the document library's
corresponding SharePoint list, are used to record the Resource and Artefact identifiers for each object/item.

This structure allows all items to be related back to their resource, and allows files to use any naming convention.

For example, a map product ('Map of Foo') consists of two distribution files (artefacts), a PDF and JPEG export.

* the identifier assigned to this product (resource) is: `24dce09c-9eee-4d90-8402-63f63012d767`
* the identifier assigned to the PDF file (artefact) is: `cb794264-e2d1-4a5a-8e31-8cf774fede54`
* the identifier assigned to the JPEG file (artefact) is: `6c21b27a-154a-488c-9ff9-764e6e9441c0`

**Note:** The resource identifiers would be assigned when the metadata record for the resource is created. Identifiers
for each artefact would be assigned when they are deposited within this service.

Conceptually, these artefacts would be stored as objects like this:

| Object Name    | Resource Identifier                    | Artefact Identifier                    |
| -------------- | -------------------------------------- | -------------------------------------- |
| `foo-map.pdf`  | `24dce09c-9eee-4d90-8402-63f63012d767` | `cb794264-e2d1-4a5a-8e31-8cf774fede54` |
| `foo-map.jpeg` | `24dce09c-9eee-4d90-8402-63f63012d767` | `6c21b27a-154a-488c-9ff9-764e6e9441c0` |

**Note:** The object names are not significant in this model, they could be named anything.

In SharePoint, artefacts would be stored like this:

```
MAGIC Products Distribution  <-- (SharePoint site)
└── Main  <-- (Document Library)
    └── 24dce09c-9eee-4d90-8402-63f63012d767  <-- (Directory for resource)
        | >> resource_id: 24dce09c-9eee-4d90-8402-63f63012d767  <-- (Custom column for resource identifier)
        | >> artefact_id: -  <-- (Custom column for artefact identifier, not applicable for directories)
        ├── foo-map.pdf  <-- (Artefact for resource)
            | >> resource_id: 24dce09c-9eee-4d90-8402-63f63012d767  <-- (Custom column for resource identifier)
            | >> artefact_id: cb794264-e2d1-4a5a-8e31-8cf774fede54  <-- (Custom column for artefact identifier)
        └── foo-map.png  <-- (Artefact for resource)
            | >> resource_id: 24dce09c-9eee-4d90-8402-63f63012d767  <-- (Custom column for resource identifier)
            | >> artefact_id: 6c21b27a-154a-488c-9ff9-764e6e9441c0  <-- (Custom column for artefact identifier)
```

**Note:** To facilitate automation, sub-directories within resource directories MUST NOT be used.

For example, this structure is NOT supported:

```
MAGIC Products Distribution
└── Main
    └── d988bfef-17af-449c-aef6-09e9936ab31a
        ├── 1-2
        │   ├── 1.txt
        │   └── 2.txt
        └── 3-4
            ├── 3.txt
            └── 4.txt
```

The supported structure for this example would be:

```
MAGIC Products Distribution
└── Main
    └── d988bfef-17af-449c-aef6-09e9936ab31a
        ├── 1.txt
        ├── 2.txt
        ├── 3.txt
        └── 4.txt
```

### SharePoint - environments

Different document libraries are used for different contexts/environments (i.e. production, testing, training, etc.).
Each library is considered isolated, and managed differently (i.e. files in a training environment may be removed at
any time, without warning etc.).

| Document Library | Environment | Notes                                              |
| ---------------- | ----------- | -------------------------------------------------- |
| Main             | Production  | Used for testing during whilst service is in Alpha |

**Note:** Additional environments will be added as this project develops.

### SharePoint - permissions

#### SharePoint permissions - overview

By default, artefacts in this service can only be accessed by members of MAGIC. In order to allow others to access them,
additional permissions can be assigned to support a range of access scenarios. These range from a set of named
individuals, through to anonymous access by the public (for unrestricted products).

Permissions are controlled by the metadata record for each product, specifically through one or more access constraints.
This service will read these constraints and convert them into suitable permission assignments within SharePoint.

**Note:** Permissions are assigned at the product (resource) level. All artefacts/files for a product will have the same
permissions.

**Note:** Multiple, different, sets of permissions can be applied to products at the same time, treated as a logical OR.
A user only needs to be included in _one_ permissions sets to access files, not _all_ permission sets.

**Note:** Permissions **SHOULD NOT** be applied directly to files within SharePoint, i.e. that are not included in the
relevant metadata record. Any ad-hoc permission assignments will be removed when the metadata record is next evaluated -
which may happen without warning.

**Note:** Permissions apply until they are revoked (by removing the relevant access constraint from the metadata record).
They are not time limited.

**Note:** Once downloaded, permissions on artefacts can no longer be enforced. I.e. A staff member could download an
artefact that is restricted to BAS staff, and then email the downloaded file to anyone, including non-staff members.

#### SharePoint permissions - metadata record encoding

Permissions to access a product's artefacts are controlled by the metadata record for the product using access
constraints. Each constraint represents a distinct set of permissions encoded as a
[JSON Web Token (JWT)](https://datatracker.ietf.org/doc/html/rfc7519).

JWTs are used because they are encoded as a URL safe string, which is the data type used by constraints in metadata
records, and because include a signature. This ensures permissions cannot be tampered with once assigned by an
authorised editor (the person writing the metadata record for the product). This step is an additional safe-guard as
metadata records may only be edited by authorised users generally.

In addition to standard JWT claims (see notes below), a private 'permissions' claim is used to encode each set of
permissions. This claim is a JSON object, the structure of which is identical to a
[driveRecipient](https://docs.microsoft.com/en-us/graph/api/resources/driverecipient) resource defined in the Microsoft
Graph API.

**Note:** As permissions do not expire (they apply until they are revoked), JWTs used for permissions do not include
the standard (but optional) `exp` (expires) claim, as its value would be arbitrary and not provide a benefit.

Example (base64 decoded) JWT representing a product restricted to a single user:

```json

```

#### Restricted to specific BAS users

...

Example access constraint (single user, 'Connie Watson'):

```json
{
    "type": "access",
    "restriction_code": "restricted",
    "permissions": {
        "email": "conwat@bas.ac.uk"
    }
}
```

...

#### Restricted to specific BAS teams

...

Example access constraint (single team, 'BAS Innovation & Impact [directorate]'):

```json
{
    "type": "access",
    "restriction_code": "restricted",
    "permissions": {
        "objectID": "06fc160e-d099-4f5b-be19-edf662030ad5"
    }
}
```

Object IDs for teams can be found through the
[Groups section](https://portal.azure.com/#blade/Microsoft_AAD_IAM/GroupsManagementMenuBlade/AllGroups) of the Azure
Active Directory via the Azure Portal.

#### Restricted to all BAS staff

... staff, students, temporary staff?, contractors? ...

Example access constraint:

```json
{
    "type": "access",
    "restriction_code": "restricted",
    "permissions": {
        "alias": "~bas"
    }
}
```

When processed, this service will create an organisation type sharing link for each file within a product's directory,
rather than assigning permissions directly to the product directory. These sharing links will be used as the URL
included in the metadata record to access each artefact from within the Data Catalogue.

...

#### Restricted to an external collaboration

...

Example access constraint:

```json

```

...

#### Conditional access - licence agreement

... use a usage constraint with an agreement ID ...

Example access constraint:

```json

```

...

#### Unrestricted access

Where a product is not sensitive, or is intended for public access, it can be marked as unrestricted. This will allow
anyone to access a product's artefacts without needing an account.

Example access constraint:

```json
{
    "type": "access",
    "restriction_code": "unrestricted"
}
```

The NERC Office 365 tenancy, within which the MAGIC Products Distribution service sits, does not allow files to be
shared externally. To workaround this and enable public access, a service principle representing anonymous users is
used.

This service principle is defined within the NERC Active Directory, and is therefore considered an internal user. The
Data Catalogue is able to use this service principle to request details of items via the Microsoft Graph API. Responses
to these API calls include a temporary pre-signed URL allowing the item to be downloaded.

When an artefact download link is followed in the Catalogue, the user-agent is redirected to this pre-signed URL to
access the file. As the pre-signed URL is time limited, this process needs to be dynamic and so is performed by the
Downloads Proxy, an AWS Lambda function that intercepts download URLs to capture download metrics.

Though considered an internal user, the anonymous service principle is not a member of the SharePoint site for this
service, and so must be assigned specific permissions to access any files. This is intentional to avoid accidentally
allowing unrestricted access to restricted items.

### SharePoint - objects reference

#### SharePoint site

ID (`{SITE_ID}`): `nercacuk.sharepoint.com,0561c437-744c-470a-887e-3d393e88e4d3,63825c43-db1b-40ca-a717-0365098c70c0`

Name: MAGICProductsDistribution

Title: MAGIC Products Distribution

URL: https://nercacuk.sharepoint.com/sites/MAGICProductsDistribution

Graph resource: https://graph.microsoft.com/v1.0/sites/nercacuk.sharepoint.com,0561c437-744c-470a-887e-3d393e88e4d3,63825c43-db1b-40ca-a717-0365098c70c0

Graph resource reference: https://docs.microsoft.com/en-us/graph/api/resources/site

**Note:** To find the ID for this resource, query the
[search](https://docs.microsoft.com/en-us/graph/api/site-search) endpoint of the sites resource in Microsoft Graph,
e.g. `https://graph.microsoft.com/v1.0/sites?search=magic`.

#### Document Library (Main/Production)

ID (`{DRIVE_ID}`): `b!N8RhBUx0CkeIfj05Pojk00NcgmMb28pApxcDZQmMcMBzlP8HkrS0TKveYyZFGRd3`

Name: Main

Title: Main

URL: https://nercacuk.sharepoint.com/sites/MAGICProductsDistribution/Main

Graph resource: https://graph.microsoft.com/v1.0/drives/b!N8RhBUx0CkeIfj05Pojk00NcgmMb28pApxcDZQmMcMBzlP8HkrS0TKveYyZFGRd3

Graph resource reference: https://docs.microsoft.com/en-us/graph/api/resources/drive

**Note:** To find the ID for this resource, query `https://graph.microsoft.com/v1.0/sites/{SITE}/drives`

#### Document Library List (Main/Production)

ID (`{LIST_ID}`): `07ff9473-b492-4cb4-abde-632645191777`

Name: Main

Title: Main

URL: https://nercacuk.sharepoint.com/sites/MAGICProductsDistribution/Main

Graph resource: https://graph.microsoft.com/v1.0/sites/nercacuk.sharepoint.com,0561c437-744c-470a-887e-3d393e88e4d3,63825c43-db1b-40ca-a717-0365098c70c0/lists/07ff9473-b492-4cb4-abde-632645191777

Graph resource reference: https://docs.microsoft.com/en-us/graph/api/resources/list

**Note:** To find the ID for this resource, query `https://graph.microsoft.com/v1.0/sites/{SITE_ID}/lists`

## Setup

### Service Principles

Contact [BAS IT](mailto:servicedesk@bas.ac.uk) to request the creation of two service accounts/principles:

1. `BAS_MAGIC_PRODUCTS_DIST_ANON_ACCESS` (BAS MAGIC Products Distribution - Anonymous Access Account)
1. `BAS_MAGIC_PRODUCTS_DIST_COND_ACCESS` (BAS MAGIC Products Distribution - Conditional Access Account)

### SharePoint

Contact [BAS IT](mailto:servicedesk@bas.ac.uk) to request a new SharePoint site:

* name: `MAGICProductsDistribution`
* title: `MAGIC Products Distribution`
* type: *Team Site* (not *Communications Hub*)
* owners:
  * one or more admin accounts (e.g. `o365conwat@bas.ac.uk`), separate from end-user accounts
* members:
  * members of the [BAS MAGIC Team](https://nercacuk.sharepoint.com/sites/BASMagicTeam), as a group
  * the `BAS_MAGIC_PRODUCTS_DIST_COND_ACCESS` service principle
* visitors: None

**Note:** Do NOT add the `BAS_MAGIC_PRODUCTS_DIST_ANON_ACCESS` service principle as a site member (or any other role).

Once created:

1. as an admin user, remove all widgets/text from the default site homepage
2. as an admin user, create a new document library:
  * name: `Main`
  * description: `Access copies of products created or managed by MAGIC for distribution. Production environment.`
  * 'show in site navigation': *False*
3. once created, add a new list column:
  * type: *Single line of text*
  * name: `resource_id`
  * description: `Resource identifier each artefact relates to`
  * default value: None
  * 'Use calculated value': *False*
  * (more options) maximum number of characters: `255`
  * (more options) 'Require that this column contains information': *True*
  * (more options) 'Enforce unique values': *False*
  * (more options) 'Add to all content types': *True*
  * (more options) column validation: None
4. once created, add a second new list column:
  * type: *Single line of text*
  * name: `artefact_id`
  * description: `Unique identifier for each resource artefact`
  * default value: None
  * 'Use calculated value': *False*
  * (more options) maximum number of characters: `255`
  * (more options) 'Require that this column contains information': *True*
  * (more options) 'Enforce unique values': *False*
  * (more options) 'Add to all content types': *True*
  * (more options) column validation: None

## Development

### Development environment

Git and [Poetry](https://python-poetry.org) are required to set up a local development environment of this project.

**Note:** If you use [Pyenv](https://github.com/pyenv/pyenv), this project sets a local Python version for consistency.

```shell
# clone from the BAS GitLab instance if possible
$ git clone ...

# setup virtual environment
$ cd magic-products-distribution
$ poetry install
```

## Deployment

...

## Release procedure

...

## Feedback

The maintainer of this project is the BAS Mapping and Geographic Information Centre (MAGIC), they can be contacted at:
[magic@bas.ac.uk](mailto:magic@bas.ac.uk).

## Issue tracking

This project uses issue tracking, see the
[Issue tracker](...) for more information.

**Note:** Read & write access to this issue tracker is restricted. Contact the project maintainer to request access.

## License

Copyright (c) 2022 UK Research and Innovation (UKRI), British Antarctic Survey.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
