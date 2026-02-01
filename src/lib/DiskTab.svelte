<script>
    import PanelButton from "./PanelButton.svelte";
    import { createEventDispatcher } from "svelte";
    import { diskLatency } from "./activities.js";
    var dispatch = createEventDispatcher();
    let state = "START";

    const trashIcon = "\u{f014}"; // nf-fa-trash_can
    function handleReset() {
        if (state == "START") state = "CONFIRM";
        else if (state == "CONFIRM") {
            state = "RESETTING";
            dispatch("reset");
        }
    }
    function getButtonText(state) {
        if (state == "START") return "Reset disk";
        else if (state == "RESETTING") return "Resetting...";
        else return "Reset disk. Confirm?";
    }
    function getBgColor(state) {
        if (state == "START") {
            // Use default
            return undefined;
        } else {
            return "bg-red-900";
        }
    }
    function getHoverColor(state) {
        if (state == "START") {
            // Use default
            return undefined;
        } else {
            return "hover:bg-red-700";
        }
    }
</script>

<PanelButton
    buttonIcon={trashIcon}
    clickHandler={handleReset}
    buttonText={getButtonText(state)}
    bgColor={getBgColor(state)}
    hoverColor={getHoverColor(state)}
></PanelButton>

<p class="mt-4">
    {#if state == "CONFIRM"}
        <span class="font-bold">Warning: </span>WebVM will reload
    {:else if state == "RESETTING"}
        <span class="font-bold">Reset in progress: </span>Please wait...
    {:else}
        <span class="font-bold">Backend latency: </span>{$diskLatency}ms
    {/if}
</p>
