#!/bin/env pwsh
param (
    [String]$Title,
    [String]$WebhookUrl,
    [String]$Version,
    [String]$ReleaseNotes,
    [String]$ReleaseHtmlUrl
)

if (-Not $WebhookUrl) {
    exit 0
}

$body = @{
    cards = @(
        @{
            header   = @{ title = $Title }
            sections = @(
                @{
                    widgets = @(
                        @{
                            keyValue = @{
                                topLabel = "Release"
                                content  = $Version
                            }
                        },
                        @{
                            keyValue = @{
                                topLabel         = "Release Notes"
                                content          = $ReleaseNotes
                                contentMultiline = "true"
                            }
                        }
                    )
                },
                @{
                    widgets = @(
                        @{
                            buttons = @(
                                @{
                                    imageButton = @{
                                        iconUrl = "https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png"
                                        onClick = @{
                                            openLink = @{
                                                url = $ReleaseHtmlUrl
                                            }
                                        }
                                    }
                                },
                                @{
                                    textButton = @{
                                        text    = "Release $Version"
                                        onClick = @{
                                            openLink = @{
                                                url = $ReleaseHtmlUrl
                                            }
                                        }
                                    }
                                }
                            )
                        }
                    )
                }
            )
        }
    )
} | ConvertTo-Json -Depth 40
Write-Host ''

Write-Host '::group::Card to be published'
Write-Host $body
Write-Host '::endgroup::'

Write-Host -ForegroundColor Green "Posting Google Space notices"
$WebhookUrl -split ';' | % {
    $response = Invoke-WebRequest -Method Post -ContentType 'application/json; charset=UTF-8' -Body $body -Uri $_
    Write-Host "Posted notice to $(($response.Content | ConvertFrom-Json).space.displayName)"
}
