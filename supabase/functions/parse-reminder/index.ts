// Supabase Edge Function: parse-reminder
// Takes raw spoken text and returns structured reminder JSON.
//
// Deploy: supabase functions deploy parse-reminder
// Set secret: supabase secrets set ANTHROPIC_API_KEY=sk-ant-...

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

const ANTHROPIC_API_KEY = Deno.env.get('ANTHROPIC_API_KEY')!;

const SYSTEM_PROMPT = `You are a reminder parser for the Anna voice assistant.
Convert spoken text into structured reminder JSON. Return ONLY valid JSON with these fields:

{
  "title": "short title of what to remind",
  "notes": "optional extra detail or null",
  "scheduled_at": "ISO 8601 datetime in user's timezone",
  "recurrence": "none" | "daily" | "weekdays" | "weekly",
  "alert_type": "alert" | "call"
}

Rules:
- If user says "call me" or implies urgency/importance, set alert_type to "call".
- If user says "every day" or "daily", set recurrence to "daily".
- If user says "weekdays" or "Mon-Fri", set recurrence to "weekdays".
- If user says "every week", set recurrence to "weekly".
- Resolve relative times ("in 30 minutes", "tomorrow at 9am") to absolute ISO timestamps.
- Use the user's local timezone provided in the request.

Return only the JSON. No explanation, no markdown fences.`;

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, content-type',
      },
    });
  }

  try {
    const { text, timezone } = await req.json();

    if (!text) {
      return new Response(JSON.stringify({ error: 'Missing text' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const now = new Date().toISOString();
    const userPrompt =
      `User said: "${text}"\n` +
      `Current time: ${now}\n` +
      `User timezone: ${timezone ?? 'UTC'}`;

    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: 'claude-haiku-4-5-20251001',
        max_tokens: 400,
        system: SYSTEM_PROMPT,
        messages: [{ role: 'user', content: userPrompt }],
      }),
    });

    if (!response.ok) {
      const errText = await response.text();
      return new Response(JSON.stringify({ error: errText }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const data = await response.json();
    const content = data.content[0].text.trim();

    // Strip markdown fences if model included them
    const cleaned = content.replace(/^```json\s*|\s*```$/g, '').trim();

    const parsed = JSON.parse(cleaned);

    return new Response(JSON.stringify(parsed), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});
