# ResourceNamer Bicep Module

## Overview

The `resourcenamer` Bicep module provides a standardized way to generate resource names according to your organization's naming conventions. This helps ensure consistency and compliance across your Azure resources.

## Usage

To use the `resourcenamer` module in your Bicep deployment, reference it in your main Bicep file:

```bicep
module resourcenamer 'modules/resourcenamer/namegenerator.bicep' = {
  name: 'resourcenamer'
  params: {
    // Provide required parameters here
    // example: prefix: 'myapp', resourceType: 'storage', environment: 'prod'
  }
}
```

## Parameters

Describe the parameters required by the module. For example:

| Name           | Type     | Description                        |
|----------------|----------|------------------------------------|
| prefix         | string   | The prefix for the resource name.   |
| resourceType   | string   | The type of Azure resource.         |
| environment    | string   | The deployment environment.         |

*Update this table to match the actual parameters in `namegenerator.bicep`.*

## Outputs

Describe the outputs provided by the module. For example:

| Name           | Type     | Description                        |
|----------------|----------|------------------------------------|
| resourceName   | string   | The generated resource name.        |

*Update this table to match the actual outputs in `namegenerator.bicep`.*

## Example

```bicep
module resourcenamer 'modules/resourcenamer/namegenerator.bicep' = {
  name: 'resourcenamer'
  params: {
    prefix: 'myapp'
    resourceType: 'storage'
    environment: 'prod'
  }
}

output generatedName string = resourcenamer.outputs.resourceName
```

## Notes
- Ensure you update the parameters and outputs sections to reflect the actual implementation in your module.
- This module is intended to be reusable across different projects and environments.
