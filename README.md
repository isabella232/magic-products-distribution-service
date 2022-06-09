# MAGIC Products Distribution

Service for distributing products produced or managed by the Mapping and Geographic Information Centre (MAGIC) at the
British Antarctic Survey (BAS).

## Overview

### Purpose

This service is intended to allow MAGIC to securely distribute products with relevant end-users.

Specifically, this service acts as a data access system, to allow links within items in the Data Catalogue (a data 
discovery system) that describe products, to be downloaded (if they have access).

### Status

This project is an early alpha working towards a Minimal Viable Product (MVP). This means:

* all, or parts, of this service may not be working
* all, or parts, of this service may stop working at any time
* all, or parts, of this service may not work correctly, or as expectedly (including destructively)
* all, or parts, of this service may change at any time (in terms of implementation or functionally)
* use-cases supported by this service are limited and restrictive
* documentation may be missing or incorrect
* no support is provided and no real and/or sensitive information should be used

### Limitations

This service has a number of limitations, including:

- products cannot use conditional access, such as agreeing to a licence before use
- products cannot be unrestricted, an alternative data access system needs to be used
- products cannot use multiple, independent, sets of access conditions for different sets of people - such as externals
- where access is restricted to a set of users, they cannot be identified using email addresses, which are easier
- where access is restricted to users or groups, these users and groups must be within the NERC Active Directory
- files to be deposited in this service must be located on the same computer used to run the tool for this service
- there is only a single, production, environment available, there is no training environment for example

See the project [issue tracker](#issue-tracking) for planned features that may address these limitations.

### Scope

#### Products

This service SHOULD be used for distributing products created or managed by MAGIC. This service MUST NOT be used for
distributing any datasets (regardless of whether they are restricted or not).

For the purposes of this service, examples of things that would be considered a *product* includes:

* maps (typically with PDF and image outputs)
* annotated images

For the purposes of this service, examples of things that would be considered a *dataset* includes:

* DEMs
* point clouds, 3D meshes and related resources
* satellite imagery
* aerial photography and RPAS imagery

**Note:** These examples are not exhaustive, and it is accepted these definitions are imperfect and subjective. 
Specific use-cases can be discussed as needed (using the *#data* channel in Slack initially).

Products and datasets are treated differently for practical and organisational reasons (e.g. storage size and the 
number of items, and that in BAS, datasets are managed by the Polar Data Centre).

#### Access only

This service is a data access system, to allow authorised end-users to access, and download copies of, Artefacts 
(files) deposited by a set of depositors (MAGIC staff). This service does not support end-users depositing products 
themselves.

#### File sizes

As soft limits:

* the total size of Artefacts for each product/Resource SHOULD NOT exceed 3GB (giving roughly 8,500 deposits)

**Note:** It is fine for some products to exceed this limit, as its assumed most products will be significantly smaller
than this limit.

As hard limits, the
[SharePoint service limits](https://docs.microsoft.com/en-us/office365/servicedescriptions/sharepoint-online-service-description/sharepoint-online-limits)
apply. Namely:

* any file MUST NOT exceed 250GB
* the total, maximum, size of all files MUST NOT exceed 25TB
* the maximum number of items (files/folders) MUST NOT exceed 30 million

## Requirements

In addition to being within the [Scope](#scope) of this service, Resources (products) MUST meet these requirements 
to be supported by this service:

**Note:** This service supports a limited set of use-cases.

1. the Resource must be considered a product within the [definition](#products) used by this service
2. the Resource (product) to be deposited MUST be described by a suitably complete metadata record [1], deposited in 
   the BAS Data Catalogue
3. the Artefacts (files) that make up each Resource (product) MUST fit within the [soft file size limits](#file-sizes)

[1] Required resource metadata:

- a `file_identifier` property with a UUIDv4 value
- a `hierarchy_level` property with a value of 'product'
- at least one resource `constraint` with:
  - a `type` property with a value of 'access'
  - a `restriction_code` property with a value of 'restricted'
  - a `permissions` property with a list of values that are objects with:
    - a `scheme` property with a value of 'ms_graph'
    - a `scheme_version` property with a value of '1'
    - a `directory_id` property with a value of 'b311db95-32ad-438f-a101-7ba061712a4e'
    - either:
      - an `alias` property with a list of values that must be one of:
        - '~nerc' (where a product should be restricted to any NERC AAD principle)
      - an `object_id` property with a list of of values that must be:
        - an object identifier of a user or group object within the NERC AAD
  - at least one `distribution` with:
    - a distributor of MAGIC
    - at least one `distribution_option` with:
      - a `transfer_option` with:
        - a `href` value containing:
          - a URI using the `file://` protocol, referencing a locally accessible file, under 5GB in size

## Usage

### Test upload script

A test script is available to check test files can be uploaded and permissions are set correctly etc. This script can be
ran within a [Development Environment](#development-environment).

```shell
$ poetry run python test-upload.py
```

**Note:** You need suitable permissions (being a member of MAGIC) to perform these instructions.

**Note:** You will be asked to sign-in to the 'MAGIC-PDC Data Workflows PoC' application when signing-in.

**Note:** This test script is not representative of how code for this service will be written.

### Manually depositing Artefacts

**Note:** These instructions should only be used as a last resort, where automated methods have failed and the need is
urgent.

**Note:** You need suitable permissions (being a member of MAGIC) to perform these instructions.

To manually deposit Artefacts (files) for a Resource (product) that meets the [Requirements](#requirements):

1. export the metadata record for the Resource (product) from the Data Catalogue
2. from the [MAGIC Products Distribution](https://nercacuk.sharepoint.com/sites/MAGICProductsDistribution/_layouts/15/viewlsts.aspx?view=14)
   SharePoint site, select the relevant document library (use 'Main' if unsure)
3. click *+ New* -> *Folder* from the toolbar
    * name the folder after the `file_identifier` property from the metadata record for the Resource
4. click *Edit in grid view* from the toolbar
    * set the 'record_id' value for the new folder to the value of the `file_identifier` property in the metadata 
      record for the Resource
    * set the 'artefact_id' value for the new folder to '-' (dash), as it doesn't apply
    * click *Exit grid view* from the toolbar
5. navigate into the newly created folder
6. for each `distribution.distribution_option` listed in the metadata record for the Resource:
    1. upload the Artefact (file) listed in the `transfer_option.online_resource.href`, either using the *Upload* 
       option in the toolbar, or by dragging & dropping into the main window
    2. click *Edit in grid view* from the toolbar:
        * set the 'record_id' value for the uploaded file to the value of the `file_identifier` property in the 
     metadata record for the Resource
        * set the 'artefact_id' value for the uploaded file to a new UUID value (using 
     [this tool](https://www.uuidgenerator.net) for example)
        * click *Exit grid view* from the toolbar
7. for each `identification.constraint` listed in the metadata record for the Resource:
    1. if the constraint permissions uses an `permissions.alias` property, with a value of `~nerc`:
        1. select each file (Artefact) within the directory for the product (Resource):
        2. click *Share* from the toolbar
        3. click *People you specify can edit*
        4. change the selection to *People in NERC with the link*
        5. deselect the *Allow editing* option under Other settings
        6. click *Apply*
        7. from the 'Copy link' section, click *Copy* to view the sharing link for the file (Artefact)
        8. note this URL for use in creating distribution options
    2. if the constraint permissions uses an `permissions.object_id` property:
        1. for each object identifier:
            1. go to the [Azure Portal](https://portal.azure.com/) [1]
            2. enter the object identifier into the global search box from the top navigation
            3. either a group or user should be returned as a result (under an 'Azure Active Directory' heading) [2]
            4. select this group or user to view its details
            5. note the value for the 'Email' property for use in assigning permissions
            6. in SharePoint, select the directory for the product (Resource)
            7. click *Open the details pane* ('i' icon) from the toolbar
            8. from the 'Has access' section, click *Manage access'
            9. from the 'Direct access' section, click *Grant Access* ('+' icon)
            10. in the 'name' field, group or email field, enter the email address noted earlier
            11. click the 'who has access' link ('pencil' icon) and select the *Can View* option ('prohibited pencil' 
                icon)
            12. do not enter a message
            13. deselect the 'Notify people' option
            14. click *Grant access*
        2. for each file (Artefact) within the directory for the product (Resource):
            1. note the URL for use in creating distributing options will be in the form of [3]
8. for each `distribution.distribution_option` listed in the metadata record for the Resource:
    1. update the `transfer_option.online_resource.href` value to use the URL noted for each distribution option
9. re-import the metadata record for the Resource (product) in the Data Catalogue

[1] Object identifiers cannot be specified when assigning permissions within the SharePoint UI. Therefore, object 
identifiers need to be converted into a corresponding email address for the group or user each identifier identifies.
Users and groups can be searched for within the NERC Active Directory using the [Azure Portal](https://portal.azure.com).

[2] If no result is returned, contact support.

[3] `https://nercacuk.sharepoint.com/sites/MAGICProductsDistribution/Main/{resource_id}/{file_name}`

Where:

* `{resource_id}` is the value of the `file_identifier` property in the metadata
* `{file_name}` is the name of the file (URl encoded and including the file extension)

For example: 

https://nercacuk.sharepoint.com/sites/MAGICProductsDistribution/Main/4a36ea8b-d4d8-4537-b46c-92f271ded940/foo-map.pdf

## Implementation

This project consists of:

* a library and service for uploading and managing files within a SharePoint document library
* a workflow for depositing files using a metadata record as input and output (writing back where files are stored)
* a tool which automates this workflow based on a selected metadata record
* documentation for using this tool, including instructions for using the workflow in a manual way

### Structure - conceptual

Conceptually, Artefacts (files) for Resources (products) are stored as objects, with tags storing unique identifiers for
each Artefact and the Resource they relate to.

For example, a map product ('Map of Foo') consists of two distribution files (Artefacts), a PDF and JPEG export.

* the identifier assigned to this product (Resource) is: `24dce09c-9eee-4d90-8402-63f63012d767`
* the identifier assigned to the PDF file (Artefact) is: `cb794264-e2d1-4a5a-8e31-8cf774fede54`
* the identifier assigned to the JPEG file (Artefact) is: `6c21b27a-154a-488c-9ff9-764e6e9441c0`

**Note:** The Resource identifier would be assigned when the metadata record for the Resource is created. Identifiers
for each Artefact would be assigned when they are deposited within this service.

Conceptually, these Artefacts would be stored as objects like this:

| Object Name    | Resource Identifier                    | Artefact Identifier                    |
| -------------- | -------------------------------------- | -------------------------------------- |
| `foo-map.pdf`  | `24dce09c-9eee-4d90-8402-63f63012d767` | `cb794264-e2d1-4a5a-8e31-8cf774fede54` |
| `foo-map.jpeg` | `24dce09c-9eee-4d90-8402-63f63012d767` | `6c21b27a-154a-488c-9ff9-764e6e9441c0` |

**Note:** Object names are not significant in this service or conceptual model, they could be anything.

### Structure - SharePoint

The conceptual structure above is implemented using SharePoint.

Artefacts are stored as files in a SharePoint document library. Files are grouped into directories named after the
Resource (product) they relate to. Two custom columns (`resource_id` and `artefact_id`), in the document library's
corresponding SharePoint list, are used to record the Resource and Artefact identifiers for each object/file.

**Note:** Files MAY be named, and renamed, using any naming scheme/convention. The `arefact_id` value MUST NOT be 
changed.

**Note:** To facilitate automation, sub-directories within Resource directories MUST NOT be used.

The 'Map of Foo' example from earlier would therefore be stored like this:

```
MAGIC Products Distribution  <-- (SharePoint site)
└── Main  <-- (Document Library)
    └── 24dce09c-9eee-4d90-8402-63f63012d767  <-- (Directory for resource)
        | >> resource_id: '24dce09c-9eee-4d90-8402-63f63012d767'  <-- (Custom column for resource identifier)
        | >> artefact_id: '-'  <-- (Custom column for artefact identifier, not applicable for directories)
        ├── foo-map.pdf  <-- (Artefact for resource)
            | >> resource_id: '24dce09c-9eee-4d90-8402-63f63012d767'  <-- (Custom column for resource identifier)
            | >> artefact_id: 'cb794264-e2d1-4a5a-8e31-8cf774fede54'  <-- (Custom column for artefact identifier)
        └── foo-map.png  <-- (Artefact for resource)
            | >> resource_id: '24dce09c-9eee-4d90-8402-63f63012d767'  <-- (Custom column for resource identifier)
            | >> artefact_id: '6c21b27a-154a-488c-9ff9-764e6e9441c0'  <-- (Custom column for artefact identifier)
```

### Environments - conceptual

Different environments are used for different contexts/purposes.

Environments are isolated from each other, meaning Artefacts deposited in, or removed from, one environment will not
appear or disappear from other environments.

A single *production* environment is currently used. Others (such as training, testing) may be added in future.

### Environments - SharePoint

Different document libraries within the same overall SharePoint site are used for each environment.

| Document Library | Environment |
| ---------------- | ----------- |
| Main             | Production  |

### Permissions - Conceptual

Conceptually, permissions for Artefacts (files) are controlled by access and usage constraints applied to Resources 
(products). This service is responsible for evaluating and enforcing these constraints.

**WARNING:** Constraints applied to Resources and their Artefacts can only be enforced at the point an Artefact is 
accessed. Once downloaded, an authorised end-user could allow an unauthorised user to access their copy without any 
permission checks, by emailing it to them for example.

Access constraints control who can access Resources. They fall into two categories:

* restricted - to a specified set of users
* unrestricted - accessible to anyone

**Note:** This service only supports *restricted* access constraints, see the [Limitations](#limitations) section 
for more information.

Usage constraints control how, and under which conditions, Resources can be used. Typically these conditions are 
within a standard or bespoke licence, which end-users may be required to agree to in order to use a Product. 

**Note:** This service does not yet support usage constraints.

### Permissions - Metadata records

Access and usage constraints (described in the previous section) for Resources (products) are defined within ISO 19115 
metadata. This service will use these constraints to apply suitable permissions to each Artefact within a Resource.

**Note:** The examples listed in this section use the JSON representation of the ISO 19139 (ISO 19115 XML encoding)
defined by the [BAS Metadata Library](https://gitlab.data.bas.ac.uk/uk-pdc/metadata-infrastructure/metadata-library),
which is typically used for authoring Resource metadata.

#### Access constraints

Access constraints are JSON objects with these properties and allowed values:

| Property                       | Type   | Required | Allowed Values                             |
|--------------------------------|--------|----------|--------------------------------------------|
| `type`                         | String | Yes      | 'access' [2]                               |
| `restriction_code`             | String | Yes      | 'restricted' [2]                           |
| `permissions`                  | Array  | Yes      | -                                          |
| `permissions.*`                | Object | Yes      | -                                          |
| `permissions.*.scheme`         | String | Yes      | 'ms_graph' [2]                             |
| `permissions.*.scheme_version` | String | Yes      | '1' [2]                                    |
| `permissions.*.directory_id`   | String | Yes      | 'b311db95-32ad-438f-a101-7ba061712a4e' [2] |
| `permissions.*.alias`          | Array  | No [1]   | -                                          |
| `permissions.*.alias.*`        | String | Yes      | '~nerc' [2]                                |
| `permissions.*.object_id`      | Array  | No [1]   | -                                          |
| `permissions.*.object_id.*`    | String | Yes      | Identifier for an object in the NERC AAD   |

[1] At least one of these properties MUST be specified.

[2] Required value. See the [Requirements](#requirements) section for more information.

For example:

```json
{
    "type": "access",
    "restriction_code": "restricted",
    "permissions": [
        {
            "scheme": "ms_graph",
            "scheme_version": "1",
            "directory_id": "b311db95-32ad-438f-a101-7ba061712a4e",
            "object_id": ["06fc160e-d099-4f5b-be19-edf662030ad5"]
        }
    ]
}
```

#### Constraints for products restricted to within NERC

Where a product is restricted, but can be accessed by anyone internally, it MUST be marked as restricted and specify a
conventional value `~nerc` to represent 'All NERC Staff'.

'All NERC Staff' in this context includes any user or service within the NERC Azure Active Directory, which includes 
(but is not limited to):

* BAS staff (inc. students)
* BGS staff
* NERC staff
* various service accounts used for automated processes and tools

**WARNING:** To stress, 'All NERC Staff' is not limited to BAS but NERC generally.

Example access constraint:

```json
{
    "type": "access",
    "restriction_code": "restricted",
    "permissions": [
        {
            "scheme": "ms_graph",
            "scheme_version": "1",
            "directory_id": "b311db95-32ad-438f-a101-7ba061712a4e",
            "alias": ["~nerc"]
        }
    ]
}
```

#### Constraints for products restricted to members of a specific team

Where a product needs to be restricted to members of a specific team, or set of teams, it MUST be marked as restricted 
and specify the identifier(s) for the Azure Active Directory group(s) that represent the relevant team(s) who's members 
should have access.

In most cases, these groups will underpin the Microsoft Office 365 Team for that team, however any group can be used
(such as project specific group or a group representing something like the BAS Management Team). All members of 
each group specified will be allowed access (i.e. a union of all group members). 

Groups are referenced using their Object Identifier (Object ID), which can be found from the 
[Groups section](https://portal.azure.com/#blade/Microsoft_AAD_IAM/GroupsManagementMenuBlade/AllGroups) of the Azure 
Active Directory in the [Azure Portal](https://portal.azure.com).

For example, the group that underpins the Microsoft Office 365 Team for MAGIC is
[`25728084-25c1-459f-999e-d42720a5f8fa`](https://portal.azure.com/#blade/Microsoft_AAD_IAM/GroupDetailsMenuBlade/Overview/groupId/25728084-25c1-459f-999e-d42720a5f8fa).

Example access constraint (single team):

```json
{
    "type": "access",
    "restriction_code": "restricted",
    "permissions": [
        {
            "scheme": "ms_graph",
            "scheme_version": "1",
            "directory_id": "b311db95-32ad-438f-a101-7ba061712a4e",
            "object_id": ["25728084-25c1-459f-999e-d42720a5f8fa"]
        }
    ]
}
```

Example access constraint (multiple teams):

```json
{
    "type": "access",
    "restriction_code": "restricted",
    "permissions": [
        {
            "scheme": "ms_graph",
            "scheme_version": "1",
            "directory_id": "b311db95-32ad-438f-a101-7ba061712a4e",
            "object_id": ["25728084-25c1-459f-999e-d42720a5f8fa", "06fc160e-d099-4f5b-be19-edf662030ad5"]
        }
    ]
}
```

#### Constraints for products restricted to a specific users

Where a product needs to be restricted to a specific user, or set of users, it MUST be marked as restricted and specify 
the identifier(s) for the Azure Active Directory user(s) that should have access.

Users are referenced using their Object Identifier (Object ID), which can be found from the 
[Users section](https://portal.azure.com/#view/Microsoft_AAD_IAM/UsersManagementMenuBlade/~/MsGraphUsers) of the Azure 
Active Directory in the [Azure Portal](https://portal.azure.com).

For example, the Object ID for *Connie Watson* is `04615595-a264-4d8d-9a95-4b1ae6c8d85e`.

Example access constraint (single user):

```json
{
    "type": "access",
    "restriction_code": "restricted",
    "permissions": [
        {
            "scheme": "ms_graph",
            "scheme_version": "1",
            "directory_id": "b311db95-32ad-438f-a101-7ba061712a4e",
            "object_id": ["04615595-a264-4d8d-9a95-4b1ae6c8d85e"]
        }
    ]
}
```

Example access constraint (multiple users):

```json
{
    "type": "access",
    "restriction_code": "restricted",
    "permissions": [
        {
            "scheme": "ms_graph",
            "scheme_version": "1",
            "directory_id": "b311db95-32ad-438f-a101-7ba061712a4e",
            "object_id": ["04615595-a264-4d8d-9a95-4b1ae6c8d85e", "7aa5b9f2-25c1-4a88-8627-c0d7d1326b55"]
        }
    ]
}
```

### Permissions - SharePoint

Permissions described by metadata record access constraints are applied to items stored in SharePoint using the 
Microsoft Graph API.

**Note:** Ad-hoc permission assignments MUST NOT be made directly within SharePoint. They may be removed or changed 
without warning by this service.

Where permissions reference the `~nerc` 'All NERC Staff' alias, an 
[Organisational sharing link](https://docs.microsoft.com/en-us/graph/api/driveitem-createlink) is created for each 
file (Artefact) associated with the Resource (product). These links will be used in distribution options, instead of 
the normal item access URL.

Where permissions reference one or more Object IDs, one or more 
[DriveRecipient](https://docs.microsoft.com/en-us/graph/api/resources/driverecipient) resources are 
[created](https://docs.microsoft.com/en-us/graph/api/driveitem-invite), granting each permission to access the 
directory representing the Resource (product). These permissions cascade to any files (Artefacts) within this directory.
Normal access URLs for each item/file are used in distribution options.

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
$ git clone https://gitlab.data.bas.ac.uk/MAGIC/products-distribution.git

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
[Issue tracker](https://gitlab.data.bas.ac.uk/MAGIC/products-distribution/-/issues) for more information.

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
