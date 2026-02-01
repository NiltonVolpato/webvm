<script>
    import {
        cpuActivity,
        diskActivity,
        cpuPercentage,
        diskLatency,
        aiActivity,
    } from "./activities.js";
    import { networkData } from "./network.js";

    export let onOpenPanel;

    const connectionState = networkData.connectionState;

    // Nerd Font icons (optimized for small terminal line rendering)
    const icons = {
        cpu: "\u{f4bc}", // nf-oct-cpu
        disk: "\u{f02ca}", // nf-md-harddisk
        wifi: "\u{f1eb}", // nf-fa-wifi
        robot: "\u{ee0d}", // nf-fa-robot (2-char width)
    };
</script>

<div
    class="flex flex-row h-6 bg-neutral-800 text-gray-300 text-xs px-4 items-center gap-4 border-t border-neutral-700"
    style="font-family: 'ZedMono NF', monospace;"
>
    <!-- CPU indicator -->
    <button
        on:click={() => onOpenPanel("cpu")}
        class="flex items-center gap-3 hover:text-white transition-colors"
    >
        <span
            class:text-amber-400={$cpuActivity}
            class:animate-pulse={$cpuActivity}
            class="w-2">{icons.cpu}</span
        >
        <span>CPU: {$cpuPercentage}%</span>
    </button>

    <span class="text-neutral-600">|</span>

    <!-- Disk indicator -->
    <button
        on:click={() => onOpenPanel("disk")}
        class="flex items-center gap-3 hover:text-white transition-colors"
    >
        <span
            class:text-amber-400={$diskActivity}
            class:animate-pulse={$diskActivity}
            class="w-2">{icons.disk}</span
        >
        <span>Disk: {$diskLatency}ms</span>
    </button>

    <span class="text-neutral-600">|</span>

    <!-- Network indicator -->
    <button
        on:click={() => onOpenPanel("network")}
        class="flex items-center gap-3 hover:text-white transition-colors"
    >
        {#if $connectionState === "CONNECTED"}
            <span class="text-green-500 w-2">{icons.wifi}</span>
            <span>Connected</span>
        {:else}
            <span class="text-gray-500 w-2">{icons.wifi}</span>
            <span>Offline</span>
        {/if}
    </button>

    <span class="text-neutral-600">|</span>

    <!-- AI indicator -->
    <button
        on:click={() => onOpenPanel("claude")}
        class="flex items-center gap-3 hover:text-white transition-colors"
    >
        <span
            class:text-amber-400={$aiActivity}
            class:animate-pulse={$aiActivity}
            class="w-2">{icons.robot}</span
        >
        {#if $aiActivity}
            <span>AI Active</span>
        {/if}
    </button>
</div>
