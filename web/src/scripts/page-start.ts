// Runs once on every page load: the pending queue's single bounded retry moment. When the
// showcase's feedback has closed, unsent reactions are cleared without being sent.
import { browserPendingQueue } from './pending-queue';
import { sendReaction } from './reaction-client';

export const FEEDBACK_CLOSED = import.meta.env.PUBLIC_FEEDBACK_CLOSED === 'true';
export const REACTIONS_URL = import.meta.env.PUBLIC_REACTIONS_URL;

export function startPendingQueue(): Promise<void> {
  const queue = browserPendingQueue();
  if (FEEDBACK_CLOSED) {
    queue.discard();
    return Promise.resolve();
  }
  return queue
    .flush((body) => sendReaction(body, { baseUrl: REACTIONS_URL }))
    .then(() => {
      document.dispatchEvent(new CustomEvent('arrowspark:queue-changed'));
    });
}
