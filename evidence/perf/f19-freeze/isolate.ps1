# F19 isolation (n9 it1): the same hunt on Vulkan, then on D3D12 with the crowd bake skipped (CB_SKIP scratch hook).
$h = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'hunt2.ps1'
& $h -Runs 10 -Tag vulkan -Driver vulkan
$env:CB_SKIP = '1'
& $h -Runs 10 -Tag nobake
$env:CB_SKIP = ''
