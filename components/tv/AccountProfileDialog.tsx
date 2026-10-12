'use client';

// =============================================================================
// PlayTogether AI — Account, Profile & Supabase Auth Modal
// Authentication, Registration, Email OTP, TOTP MFA, and Guest Mode.
// =============================================================================

import React, { useState, useEffect } from 'react';
import { X, User, ShieldCheck, Mail, Lock, KeyRound, CheckCircle, LogOut, Sparkles, Smartphone } from 'lucide-react';
import { TVFocusable } from './TVFocusManager';
import { Player } from '@/lib/types';

export interface AccountProfileDialogProps {
  isOpen: boolean;
  onClose: () => void;
  players?: Player[];
  activeSessionId?: string;
}

export function AccountProfileDialog({
  isOpen,
  onClose,
  players = [],
  activeSessionId = 'PLAY-26',
}: AccountProfileDialogProps) {
  // Auth view mode: 'profile' | 'signin' | 'signup' | 'otp' | 'mfa'
  const [authMode, setAuthMode] = useState<'profile' | 'signin' | 'signup' | 'otp' | 'mfa'>('profile');
  const [currentUser, setCurrentUser] = useState<any>(null);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [errorMsg, setErrorMsg] = useState<string>('');
  const [successMsg, setSuccessMsg] = useState<string>('');

  // Form states
  const [email, setEmail] = useState<string>('');
  const [password, setPassword] = useState<string>('');
  const [otpToken, setOtpToken] = useState<string>('');
  const [mfaCode, setMfaCode] = useState<string>('');
  const [mfaFactorId, setMfaFactorId] = useState<string>('');
  const [mfaChallengeId, setMfaChallengeId] = useState<string>('');
  const [totpQrUri, setTotpQrUri] = useState<string>('');

  // Check current session
  useEffect(() => {
    if (!isOpen) return;
    const fetchUser = async () => {
      try {
        const res = await fetch('/api/auth/user');
        const data = await res.json();
        if (data.authenticated) {
          setCurrentUser(data.user);
          setAuthMode('profile');
        } else {
          setCurrentUser(null);
        }
      } catch {
        setCurrentUser(null);
      }
    };
    fetchUser();
  }, [isOpen]);

  if (!isOpen) return null;

  const handleSignIn = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setErrorMsg('');
    try {
      const res = await fetch('/api/auth/signin', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      });
      const data = await res.json();
      if (!res.ok) {
        setErrorMsg(data.error || 'Login failed');
      } else if (data.mfaRequired) {
        setMfaFactorId(data.factorId);
        // Create challenge
        const cRes = await fetch('/api/auth/mfa/challenge', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ factorId: data.factorId }),
        });
        const cData = await cRes.json();
        if (cRes.ok) {
          setMfaChallengeId(cData.challengeId);
          setAuthMode('mfa');
        }
      } else {
        setSuccessMsg('Signed in successfully!');
        setCurrentUser(data.user);
        setAuthMode('profile');
      }
    } catch (err: any) {
      setErrorMsg(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSignUp = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setErrorMsg('');
    try {
      const res = await fetch('/api/auth/signup', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      });
      const data = await res.json();
      if (!res.ok) {
        setErrorMsg(data.error || 'Signup failed');
      } else {
        setSuccessMsg('Verification code sent to your email!');
        setAuthMode('otp');
      }
    } catch (err: any) {
      setErrorMsg(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  const handleVerifyOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setErrorMsg('');
    try {
      const res = await fetch('/api/auth/verify-otp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, token: otpToken, type: 'signup' }),
      });
      const data = await res.json();
      if (!res.ok) {
        setErrorMsg(data.error || 'Verification failed');
      } else {
        setSuccessMsg('Account verified!');
        setCurrentUser(data.user);
        setAuthMode('profile');
      }
    } catch (err: any) {
      setErrorMsg(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  const handleEnrollMfa = async () => {
    setIsLoading(true);
    setErrorMsg('');
    try {
      const res = await fetch('/api/auth/mfa/enroll', {
        method: 'POST',
      });
      const data = await res.json();
      if (!res.ok) {
        setErrorMsg(data.error || 'MFA enrollment failed');
      } else {
        setMfaFactorId(data.factorId);
        setTotpQrUri(data.totp.uri);
        // Create challenge
        const cRes = await fetch('/api/auth/mfa/challenge', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ factorId: data.factorId }),
        });
        const cData = await cRes.json();
        setMfaChallengeId(cData.challengeId);
        setAuthMode('mfa');
      }
    } catch (err: any) {
      setErrorMsg(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  const handleVerifyMfa = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setErrorMsg('');
    try {
      const res = await fetch('/api/auth/mfa/verify', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          factorId: mfaFactorId,
          challengeId: mfaChallengeId,
          code: mfaCode,
        }),
      });
      const data = await res.json();
      if (!res.ok) {
        setErrorMsg(data.error || 'MFA code incorrect');
      } else {
        setSuccessMsg('MFA Authenticated!');
        setAuthMode('profile');
      }
    } catch (err: any) {
      setErrorMsg(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSignOut = async () => {
    setIsLoading(true);
    try {
      await fetch('/api/auth/signout', { method: 'POST' });
      setCurrentUser(null);
      setSuccessMsg('Signed out');
      setAuthMode('signin');
    } catch {
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-md p-6 select-none animate-fadeIn">
      <div className="w-full max-w-xl bg-surface-low rounded-3xl border border-secondary/50 shadow-2xl p-8 text-white relative">
        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-6 right-6 p-2 rounded-xl text-slate-400 hover:text-white hover:bg-surface-high transition"
          aria-label="Close"
        >
          <X className="w-6 h-6" />
        </button>

        {/* Modal Header */}
        <div className="flex items-center gap-3 mb-6 pb-4 border-b border-outline-variant/40">
          <div className="w-10 h-10 rounded-xl bg-purple-900/50 border border-purple-400/40 flex items-center justify-center">
            <ShieldCheck className="w-6 h-6 text-purple-300" />
          </div>
          <div>
            <h2 className="font-space font-bold text-xl text-white">
              {authMode === 'profile'
                ? 'Host Account & Room Profile'
                : authMode === 'signup'
                ? 'Create Host Account'
                : authMode === 'otp'
                ? 'Verify Email OTP'
                : authMode === 'mfa'
                ? 'Two-Factor Authentication (MFA)'
                : 'Sign In to PlayTogether AI'}
            </h2>
            <p className="text-xs text-slate-400">
              Supabase Authentication • Living Room Session #{activeSessionId.replace('session_', '')}
            </p>
          </div>
        </div>

        {/* Alerts */}
        {errorMsg && (
          <div className="p-3 mb-4 rounded-xl bg-rose-950/60 border border-rose-500/50 text-rose-200 text-xs">
            {errorMsg}
          </div>
        )}
        {successMsg && (
          <div className="p-3 mb-4 rounded-xl bg-emerald-950/60 border border-emerald-500/50 text-emerald-200 text-xs flex items-center gap-2">
            <CheckCircle className="w-4 h-4 text-emerald-400" />
            <span>{successMsg}</span>
          </div>
        )}

        {/* MODE 1: Profile View */}
        {authMode === 'profile' && (
          <div className="space-y-5">
            {currentUser ? (
              <div className="p-4 rounded-2xl bg-surface border border-outline-variant/60 flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 rounded-full bg-cyan-500/20 border border-cyan-400/40 flex items-center justify-center">
                    <User className="w-6 h-6 text-cyan-300" />
                  </div>
                  <div>
                    <h3 className="font-bold text-white text-sm">{currentUser.displayName || currentUser.email}</h3>
                    <p className="text-xs text-slate-400">{currentUser.email}</p>
                    <div className="flex items-center gap-2 mt-1">
                      <span className="px-2 py-0.5 rounded bg-emerald-500/20 text-emerald-300 text-[10px] font-mono">
                        VERIFIED
                      </span>
                      {currentUser.mfaEnabled ? (
                        <span className="px-2 py-0.5 rounded bg-purple-500/20 text-purple-300 text-[10px] font-mono">
                          MFA ACTIVE
                        </span>
                      ) : (
                        <span className="px-2 py-0.5 rounded bg-amber-500/20 text-amber-300 text-[10px] font-mono">
                          MFA INACTIVE
                        </span>
                      )}
                    </div>
                  </div>
                </div>

                <button
                  onClick={handleSignOut}
                  disabled={isLoading}
                  className="px-3 py-1.5 rounded-xl bg-rose-950/50 hover:bg-rose-900 border border-rose-500/40 text-rose-300 text-xs flex items-center gap-1.5 transition"
                >
                  <LogOut className="w-3.5 h-3.5" />
                  <span>Logout</span>
                </button>
              </div>
            ) : (
              <div className="p-4 rounded-2xl bg-surface border border-outline-variant/60">
                <div className="flex items-center gap-2 text-amber-300 text-xs font-semibold mb-1">
                  <Sparkles className="w-4 h-4" />
                  <span>Playing as Living Room Guest (Family Mode)</span>
                </div>
                <p className="text-xs text-slate-400 mb-4">
                  Scores and sessions are persisted to Supabase database. Sign in or register to sync stats across TV devices.
                </p>
                <div className="flex gap-3">
                  <TVFocusable
                    id="profile-btn-login"
                    group="account-modal"
                    onActivate={() => setAuthMode('signin')}
                    className="flex-1 py-2 text-center rounded-xl bg-primary-container text-white text-xs font-bold shadow"
                  >
                    Sign In
                  </TVFocusable>
                  <TVFocusable
                    id="profile-btn-register"
                    group="account-modal"
                    onActivate={() => setAuthMode('signup')}
                    className="flex-1 py-2 text-center rounded-xl bg-surface-high border border-outline-variant text-slate-200 text-xs font-bold"
                  >
                    Create Account
                  </TVFocusable>
                </div>
              </div>
            )}

            {/* MFA Setup button if logged in but without MFA */}
            {currentUser && !currentUser.mfaEnabled && (
              <div className="p-3.5 rounded-xl bg-surface-high/60 border border-purple-500/30 flex items-center justify-between">
                <div className="flex items-center gap-2.5">
                  <Smartphone className="w-4 h-4 text-purple-400" />
                  <span className="text-xs text-slate-300">Protect account with Authenticator TOTP</span>
                </div>
                <button
                  onClick={handleEnrollMfa}
                  disabled={isLoading}
                  className="px-3 py-1 rounded-lg bg-purple-600 hover:bg-purple-500 text-white text-xs font-medium transition"
                >
                  Enroll MFA
                </button>
              </div>
            )}

            {/* Active Players Roster */}
            <div>
              <div className="text-xs font-mono text-slate-400 mb-2">
                ACTIVE PLAYERS SYNCED IN THIS ROOM ({players.length}):
              </div>
              <div className="grid grid-cols-2 gap-2">
                {players.map((p) => (
                  <div
                    key={p.id}
                    className="p-2.5 rounded-xl bg-surface-high/80 border border-outline-variant/40 flex items-center justify-between text-xs"
                  >
                    <div className="flex items-center gap-2">
                      <span className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: p.accentColor }} />
                      <span className="font-semibold text-white">{p.name}</span>
                    </div>
                    <span className="text-slate-400 font-mono">{p.score} PTS</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* MODE 2: Sign In */}
        {authMode === 'signin' && (
          <form onSubmit={handleSignIn} className="space-y-4">
            <div>
              <label className="block text-xs font-mono text-slate-400 mb-1">Email Address</label>
              <div className="relative">
                <Mail className="absolute left-3 top-3 w-4 h-4 text-slate-400" />
                <input
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="family@example.com"
                  className="w-full pl-9 pr-3 py-2.5 rounded-xl bg-surface border border-outline-variant/60 focus:border-secondary text-white text-sm outline-none"
                />
              </div>
            </div>
            <div>
              <label className="block text-xs font-mono text-slate-400 mb-1">Password</label>
              <div className="relative">
                <Lock className="absolute left-3 top-3 w-4 h-4 text-slate-400" />
                <input
                  type="password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full pl-9 pr-3 py-2.5 rounded-xl bg-surface border border-outline-variant/60 focus:border-secondary text-white text-sm outline-none"
                />
              </div>
            </div>

            <div className="pt-2 flex gap-3">
              <button
                type="submit"
                disabled={isLoading}
                className="flex-1 py-2.5 rounded-xl bg-primary-container text-white font-bold text-sm hover:brightness-110 transition"
              >
                {isLoading ? 'Signing in...' : 'Sign In [OK]'}
              </button>
              <button
                type="button"
                onClick={() => setAuthMode('signup')}
                className="px-4 py-2.5 rounded-xl bg-surface-high border border-outline-variant text-slate-300 text-xs"
              >
                Register
              </button>
            </div>
          </form>
        )}

        {/* MODE 3: Sign Up */}
        {authMode === 'signup' && (
          <form onSubmit={handleSignUp} className="space-y-4">
            <div>
              <label className="block text-xs font-mono text-slate-400 mb-1">Email Address</label>
              <div className="relative">
                <Mail className="absolute left-3 top-3 w-4 h-4 text-slate-400" />
                <input
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="family@example.com"
                  className="w-full pl-9 pr-3 py-2.5 rounded-xl bg-surface border border-outline-variant/60 focus:border-secondary text-white text-sm outline-none"
                />
              </div>
            </div>
            <div>
              <label className="block text-xs font-mono text-slate-400 mb-1">Password</label>
              <div className="relative">
                <Lock className="absolute left-3 top-3 w-4 h-4 text-slate-400" />
                <input
                  type="password"
                  required
                  minLength={6}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="At least 6 characters"
                  className="w-full pl-9 pr-3 py-2.5 rounded-xl bg-surface border border-outline-variant/60 focus:border-secondary text-white text-sm outline-none"
                />
              </div>
            </div>

            <div className="pt-2 flex gap-3">
              <button
                type="submit"
                disabled={isLoading}
                className="flex-1 py-2.5 rounded-xl bg-secondary text-slate-950 font-bold text-sm hover:brightness-110 transition"
              >
                {isLoading ? 'Sending verification...' : 'Create Account & Send OTP'}
              </button>
              <button
                type="button"
                onClick={() => setAuthMode('signin')}
                className="px-4 py-2.5 rounded-xl bg-surface-high border border-outline-variant text-slate-300 text-xs"
              >
                Sign In
              </button>
            </div>
          </form>
        )}

        {/* MODE 4: OTP Verification */}
        {authMode === 'otp' && (
          <form onSubmit={handleVerifyOtp} className="space-y-4">
            <p className="text-xs text-slate-300">
              Enter the 6-digit confirmation code sent to <strong className="text-secondary">{email}</strong>.
            </p>
            <div>
              <div className="relative">
                <KeyRound className="absolute left-3 top-3 w-4 h-4 text-slate-400" />
                <input
                  type="text"
                  required
                  maxLength={8}
                  value={otpToken}
                  onChange={(e) => setOtpToken(e.target.value)}
                  placeholder="123456"
                  className="w-full pl-9 pr-3 py-2.5 rounded-xl bg-surface border border-outline-variant/60 focus:border-secondary text-white text-center font-mono tracking-widest text-lg outline-none"
                />
              </div>
            </div>

            <div className="pt-2 flex gap-3">
              <button
                type="submit"
                disabled={isLoading}
                className="flex-1 py-2.5 rounded-xl bg-emerald-500 text-slate-950 font-bold text-sm hover:brightness-110 transition"
              >
                {isLoading ? 'Verifying...' : 'Verify Email [OK]'}
              </button>
              <button
                type="button"
                onClick={() => setAuthMode('signin')}
                className="px-4 py-2.5 rounded-xl bg-surface-high border border-outline-variant text-slate-300 text-xs"
              >
                Cancel
              </button>
            </div>
          </form>
        )}

        {/* MODE 5: MFA Verification */}
        {authMode === 'mfa' && (
          <form onSubmit={handleVerifyMfa} className="space-y-4">
            <p className="text-xs text-slate-300">
              Enter the 6-digit code from your Authenticator App:
            </p>
            {totpQrUri && (
              <div className="p-3 bg-surface rounded-xl border border-outline-variant text-center">
                <span className="text-[10px] text-slate-400">TOTP Setup URI:</span>
                <p className="text-[10px] font-mono text-cyan-300 break-all select-all">{totpQrUri}</p>
              </div>
            )}
            <div>
              <input
                type="text"
                required
                maxLength={6}
                value={mfaCode}
                onChange={(e) => setMfaCode(e.target.value)}
                placeholder="000000"
                className="w-full py-2.5 rounded-xl bg-surface border border-outline-variant/60 focus:border-secondary text-white text-center font-mono tracking-widest text-2xl outline-none"
              />
            </div>
            <div className="pt-2 flex gap-3">
              <button
                type="submit"
                disabled={isLoading}
                className="flex-1 py-2.5 rounded-xl bg-purple-600 text-white font-bold text-sm hover:brightness-110 transition"
              >
                {isLoading ? 'Verifying...' : 'Confirm MFA Code [OK]'}
              </button>
              <button
                type="button"
                onClick={() => setAuthMode('profile')}
                className="px-4 py-2.5 rounded-xl bg-surface-high border border-outline-variant text-slate-300 text-xs"
              >
                Cancel
              </button>
            </div>
          </form>
        )}

        {/* Footer */}
        <div className="mt-6 pt-4 border-t border-slate-800 flex justify-between items-center text-xs text-slate-500">
          <span>Row Level Security (RLS) Active</span>
          <button onClick={onClose} className="hover:text-white transition">
            Close [Esc]
          </button>
        </div>
      </div>
    </div>
  );
}

export default AccountProfileDialog;
