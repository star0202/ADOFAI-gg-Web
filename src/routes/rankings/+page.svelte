<script lang="ts">
  import { browser } from '$app/environment';
  import { api } from '@/api';

  import LoadingSpinner from '@atoms/common/LoadingSpinner.svelte';
  import MainSectionTitle from '@atoms/common/MainSectionTitle.svelte';
  import PageContainer from '@atoms/common/PageContainer.svelte';
  import RankingListItem from '@organisms/rankings/RankingListItem.svelte';
  import RankingTopItem from '@organisms/rankings/RankingTopItem.svelte';
  import type { ListResponse } from '@/types';
  import VirtualizedInfiniteScroll from '@adofai-gg/svelte-virtualized-infinite-scroll';
  import { onMount } from 'svelte';
  import { writable } from 'svelte/store';
  import type { RankingResult } from './+page';

  let items = writable<RankingResult[]>([]);

  let total = 0;

  let offsets = writable<number[]>([]);

  $: loadMore = async (offset = 0) => {
    offsets.update((x) => [...x, offset]);

    const { data } = await api.get<ListResponse<RankingResult>>('/api/v1/ranking', {
      params: { offset, amount: 30 }
    });

    const results = data.results.map((x, i) => ({ ...x, rank: offset + i + 1 }));

    if (offset === 0) items.set(results);
    else items.update((x) => [...x, ...results]);
    total = data.count;
  };

  onMount(async () => {
    total = (
      await api.get<ListResponse<RankingResult>>('/api/v1/ranking', {
        params: { amount: 1, offset: 0 }
      })
    ).data.count;

    const contentWrapper = document.querySelector('.simplebar-content-wrapper');

    setTimeout(() => {
      contentWrapper?.scrollTo({
        top: 0,
        behavior: 'smooth'
      });
    }, 100);
  });

  $: onMore = (e: CustomEvent<{ offset: number }>) => {
    loadMore(e.detail.offset ? e.detail.offset + 3 : 0);
  };

  $: topItems = $items.slice(0, 3);

  $: listItems = $items.slice(3);
</script>

<div class="nav-spacer" />

<PageContainer>
  <div class="top-spacer">
    <MainSectionTitle title="RANKING_TITLE" />
  </div>
  {#if browser}
    <div class="top-rankings">
      {#each topItems as item}
        <RankingTopItem {item} />
      {/each}
    </div>
    <VirtualizedInfiniteScroll
      scrollContainer="#root"
      data={listItems}
      on:more={onMore}
      let:item
      total={Math.max(0, total - 3)}
    >
      <RankingListItem {item} />
      <div slot="loading" class="loader">
        <LoadingSpinner size={48} />
      </div>
    </VirtualizedInfiniteScroll>
  {/if}
</PageContainer>

<style lang="scss">
  .nav-spacer {
    height: var(--nav-height);
  }

  .top-spacer {
    margin-top: 24px;
  }

  .top-rankings {
    display: flex;
    flex-direction: column;
    gap: 24px;
    margin-bottom: 16px;

    @media (min-width: 768px) {
      display: grid;
      grid-template-columns: 1fr 1fr;
    }

    @media (min-width: 1024px) {
      grid-template-columns: 1fr 1fr 1fr;
    }
  }

  .loader {
    display: flex;
    justify-content: center;
    width: 100%;
  }
</style>
