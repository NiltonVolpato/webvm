<script>
    import PanelButton from "./PanelButton.svelte";
    import { cpuPercentage } from "./activities.js";
</script>

<p>
    <span class="font-bold">Virtual CPU: </span>{$cpuPercentage}%
</p>
