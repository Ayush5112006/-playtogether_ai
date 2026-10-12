import { describe, it, expect } from 'vitest';
import { Player } from '@/lib/types';
import { sortPlayersDeterministically } from '@/lib/game-engine/scoring';

describe('Family Member & Living Room Roster Management', () => {
  const initialPlayers: Player[] = [
    { id: 'p1', name: 'Dad (Mark)', avatar: '👨‍💼', ageGroup: 'adult', roleTag: 'Family Tactician', score: 450, streak: 3 },
    { id: 'p2', name: 'Mom (Sarah)', avatar: '👩‍🏫', ageGroup: 'adult', roleTag: 'Pop Culture Queen', score: 380, streak: 1 },
    { id: 'p3', name: 'Leo', avatar: '👦', ageGroup: 'child', roleTag: 'Speed Buzzer Demon', score: 520, streak: 4 },
    { id: 'p4', name: 'Grandma (Elena)', avatar: '👵', ageGroup: 'senior', roleTag: 'History Sage', score: 410, streak: 2 },
  ];

  it('allows adding a new family member with child handicap age group', () => {
    const newMember: Player = {
      id: 'p_test_5',
      name: 'Sister (Maya)',
      avatar: '👧',
      ageGroup: 'child',
      roleTag: 'Wildcard Gamer',
      color: '#ec4899',
      score: 0,
      streak: 0,
    };

    const updatedRoster = [...initialPlayers, newMember];
    expect(updatedRoster).toHaveLength(5);
    expect(updatedRoster[4].name).toBe('Sister (Maya)');
    expect(updatedRoster[4].ageGroup).toBe('child');
    expect(updatedRoster[4].roleTag).toBe('Wildcard Gamer');
  });

  it('allows adding a senior family member with pacing boost', () => {
    const grandpa: Player = {
      id: 'p_test_6',
      name: 'Grandpa (George)',
      avatar: '👴',
      ageGroup: 'senior',
      roleTag: 'History Sage',
      color: '#f59e0b',
      score: 0,
      streak: 0,
    };

    const updatedRoster = [...initialPlayers, grandpa];
    expect(updatedRoster).toHaveLength(5);
    expect(updatedRoster[4].ageGroup).toBe('senior');
  });

  it('enforces maximum 8 family members living room capacity', () => {
    let roster = [...initialPlayers];
    const maxCapacity = 8;

    for (let i = roster.length; i < maxCapacity; i++) {
      roster.push({
        id: `p_extra_${i}`,
        name: `Guest ${i + 1}`,
        score: 0,
        streak: 0,
      });
    }

    expect(roster).toHaveLength(8);

    // Attempting to exceed 8
    const tryAddMore = (currentRoster: Player[], newP: Player): Player[] => {
      if (currentRoster.length >= 8) return currentRoster;
      return [...currentRoster, newP];
    };

    const ninthPlayer: Player = {
      id: 'p_extra_9',
      name: 'Player 9',
      score: 0,
      streak: 0,
    };

    const finalRoster = tryAddMore(roster, ninthPlayer);
    expect(finalRoster).toHaveLength(8);
  });

  it('preserves deterministic ranking when family members update scores', () => {
    const scoredPlayers: Player[] = [
      { id: 'p1', name: 'Dad', score: 300, streak: 2 },
      { id: 'p2', name: 'Mom', score: 500, streak: 4 },
      { id: 'p3', name: 'Leo (Child)', score: 700, streak: 5 },
      { id: 'p4', name: 'Grandma (Senior)', score: 500, streak: 5 },
    ];

    const sorted = sortPlayersDeterministically(scoredPlayers);
    expect(sorted[0].name).toBe('Leo (Child)'); // 700
    expect(sorted[1].name).toBe('Grandma (Senior)'); // 500 with streak 5 > streak 4
    expect(sorted[2].name).toBe('Mom'); // 500 with streak 4
    expect(sorted[3].name).toBe('Dad'); // 300
  });

  it('allows removing a family member while preserving minimum 2 players', () => {
    const canRemove = (roster: Player[], idToRemove: string): Player[] => {
      if (roster.length <= 2) return roster;
      return roster.filter((p) => p.id !== idToRemove);
    };

    let roster = [...initialPlayers];
    roster = canRemove(roster, 'p4');
    expect(roster).toHaveLength(3);

    roster = canRemove(roster, 'p3');
    expect(roster).toHaveLength(2);

    // Cannot remove below 2
    roster = canRemove(roster, 'p2');
    expect(roster).toHaveLength(2);
  });
});
