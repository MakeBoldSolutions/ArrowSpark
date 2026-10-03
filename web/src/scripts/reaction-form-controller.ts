// Wires a reaction form (game or story) to the client and the pending queue.
import { getLatestAttempt } from './game-bridge';
import { browserPendingQueue } from './pending-queue';
import { submitReaction } from './reaction-client';
import { RESULT_MESSAGES, buildGameReaction, buildStoryReaction, isEmptyReaction } from './reaction-forms';
import { REACTIONS_URL } from './page-start';

export function initReactionForm(form: HTMLFormElement): void {
  const kind = form.dataset.reactionKind;
  const status = form.querySelector<HTMLElement>('[data-reaction-status]');
  const submit = form.querySelector<HTMLButtonElement>('[data-reaction-submit]');
  const pendingNote = form.querySelector<HTMLElement>('[data-reaction-pending]');
  const discard = form.querySelector<HTMLButtonElement>('[data-reaction-discard]');
  const queue = browserPendingQueue();

  const refreshPending = () => {
    const count = queue.available() ? queue.entries().length : 0;
    if (pendingNote) {
      pendingNote.hidden = count === 0;
      const counter = pendingNote.querySelector('[data-reaction-count]');
      if (counter) counter.textContent = count === 1 ? '1 reaction is' : `${count} reactions are`;
    }
  };
  refreshPending();
  document.addEventListener('arrowspark:queue-changed', refreshPending);

  discard?.addEventListener('click', () => {
    queue.discard();
    refreshPending();
    if (status) status.textContent = 'Unsent feedback discarded from this device.';
  });

  form.addEventListener('submit', (event) => {
    event.preventDefault();
    const data = new FormData(form);
    const answers: Record<string, string> = {};
    data.forEach((value, key) => {
      if (typeof value === 'string') answers[key] = value;
    });
    const body = kind === 'game' ? buildGameReaction(answers, getLatestAttempt()) : buildStoryReaction(answers);
    if (isEmptyReaction(body)) {
      if (status) status.textContent = RESULT_MESSAGES.empty;
      return;
    }
    if (!queue.available()) {
      if (status) status.textContent = RESULT_MESSAGES.unavailable;
    }
    if (submit) submit.disabled = true;
    if (status) status.textContent = 'Sending…';
    void submitReaction(body, queue, { baseUrl: REACTIONS_URL }).then((result) => {
      if (status) status.textContent = RESULT_MESSAGES[result];
      // A sent reaction closes the form for this visit, so a double click can't send it twice.
      if (submit) submit.disabled = result === 'sent' || result === 'saved';
      if (result === 'sent' || result === 'saved') {
        for (const field of form.querySelectorAll<HTMLInputElement | HTMLTextAreaElement>('input, textarea')) field.disabled = true;
      }
      refreshPending();
    });
  });
}
