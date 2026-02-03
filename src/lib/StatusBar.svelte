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
    export let onUpload = null;

    const connectionState = networkData.connectionState;

    // Nerd Font icons (optimized for small terminal line rendering)
    const icons = {
        cpu: "\u{f4bc}\u{00a0}", // nf-oct-cpu
        disk: "\u{f02ca}", // nf-md-harddisk
        wifi: "\u{f1eb}\u{00a0}", // nf-fa-wifi
        robot: "\u{ee0d}\u{00a0}", // nf-fa-robot (2-char width)
        upload: "\u{f40a}\u{00a0}", // nf-oct-upload
    };

    let fileInput;

    function handleUploadClick() {
        fileInput?.click();
    }

    async function handleFileSelect(event) {
        const file = event.target.files?.[0];
        if (file && onUpload) {
            await onUpload(file);
        }
        // Reset input so same file can be selected again
        event.target.value = "";
    }
</script>

<div
    class="flex flex-row h-6 bg-neutral-800 text-gray-300 text-xs px-4 items-center gap-2 border-t border-neutral-700"
    style="font-family: 'ZedMono NF', monospace;"
>
    <!-- CPU indicator -->
    <button
        on:click={() => onOpenPanel("cpu")}
        class="flex items-center gap-2 hover:text-white transition-colors"
    >
        <span
            class:text-amber-400={$cpuActivity}
            class:animate-pulse={$cpuActivity}
            class="self-stretch min-w-[1lh] inline-flex items-center justify-center"
            >{icons.cpu}</span
        >
        <span>CPU: {$cpuPercentage}%</span>
    </button>

    <span class="text-neutral-600">|</span>

    <!-- Disk indicator -->
    <button
        on:click={() => onOpenPanel("disk")}
        class="flex items-center gap-2 hover:text-white transition-colors"
    >
        <span
            class:text-amber-400={$diskActivity}
            class:animate-pulse={$diskActivity}
            class="self-stretch min-w-[1lh] inline-flex items-center justify-center"
            >{icons.disk}</span
        >
        <span>Disk: {$diskLatency}ms</span>
    </button>

    <span class="text-neutral-600">|</span>

    <!-- Network indicator -->
    <button
        on:click={() => onOpenPanel("network")}
        class="flex items-center gap-2 hover:text-white transition-colors"
    >
        {#if $connectionState === "CONNECTED"}
            <span
                class="text-green-500 self-stretch min-w-[1lh] inline-flex items-center justify-center"
                >{icons.wifi}</span
            >
            <span>Connected</span>
        {:else}
            <span
                class="text-gray-500 self-stretch min-w-[1lh] inline-flex items-center justify-center"
                >{icons.wifi}</span
            >
            <span>Offline</span>
        {/if}
    </button>

    <span class="text-neutral-600">|</span>

    <!-- AI indicator -->
    <button
        on:click={() => onOpenPanel("claude")}
        class="flex items-center gap-2 hover:text-white transition-colors"
    >
        <span
            class:text-amber-400={$aiActivity}
            class:animate-pulse={$aiActivity}
            class="self-stretch min-w-[1lh] inline-flex items-center justify-center"
            >{icons.robot}</span
        >
        {#if $aiActivity}
            <span>AI Active</span>
        {/if}
    </button>

    {#if onUpload}
        <span class="text-neutral-600">|</span>

        <!-- Upload file to VM -->
        <button
            on:click={handleUploadClick}
            class="flex items-center gap-2 hover:text-white transition-colors"
            title="Upload file to VM"
        >
            <span
                class="self-stretch min-w-[1lh] inline-flex items-center justify-center"
                >{icons.upload}</span
            >
        </button>
        <input
            type="file"
            bind:this={fileInput}
            on:change={handleFileSelect}
            class="hidden"
        />
    {/if}
</div>
