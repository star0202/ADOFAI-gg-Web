<script lang="ts">
  import { browser } from '$app/environment';
  import { api } from '@/api';

  import LoadingSpinner from '@atoms/common/LoadingSpinner.svelte';
  import SectionTitle from '@atoms/common/MainSectionTitle.svelte';
  import type { ListResponse, PlayLog } from '@/types';
  import LevelLeaderboardItem from '@organisms/levels/info/LevelLeaderboardItem.svelte';

  export let levelId: number;

  $: promise = browser
    ? api
        .get<ListResponse<PlayLog>>('/api/v1/playLogs', {
          params: {
            levelId,
            offset: 0,
            amount: 10,
            sort: 'PP_DESC'
          }
        })
        .then((x) => x.data.results)
    : null;
</script>

{#if promise}
  {#await promise}
    <div class="loading">
      <LoadingSpinner />
    </div>
  {:then data}
    {#if data.length}
      <div>
        <SectionTitle title="LEVEL_LEADERBOARD" />

        <div class="list">
          {#each Object.entries(data) as [index, item]}
            <LevelLeaderboardItem index={Number(index)} play={item} />
          {/each}
        </div>
      </div>
    {/if}
  {/await}
{/if}

<style lang="scss">
  .loading {
    display: flex;
    justify-content: center;
  }

  .list {
    display: flex;
    flex-direction: column;
    margin-top: -24px;
  }
</style>
