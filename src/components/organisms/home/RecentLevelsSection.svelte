<script lang="ts">
  import MainSectionTitle from '@atoms/common/MainSectionTitle.svelte';
  import type { Level } from '@/types';
  import LevelListItem from '@organisms/levels/list/LevelListItem.svelte';

  export let levels: Level[];
</script>

<MainSectionTitle title="HOME_RECENT_LEVELS" moreLink="/levels" />

<div style="margin-top: -18px;">
  {#each levels as level}
    <LevelListItem {level} />
  {/each}
</div>
