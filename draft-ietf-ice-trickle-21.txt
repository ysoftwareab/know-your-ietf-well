



Network Working Group                                            E. Ivov
Internet-Draft                                                 Atlassian
Intended status: Standards Track                             E. Rescorla
Expires: October 17, 2018                                     RTFM, Inc.
                                                               J. Uberti
                                                                  Google
                                                          P. Saint-Andre
                                                                 Mozilla
                                                          April 15, 2018


Trickle ICE: Incremental Provisioning of Candidates for the Interactive
               Connectivity Establishment (ICE) Protocol
                       draft-ietf-ice-trickle-21

Abstract

   This document describes "Trickle ICE", an extension to the
   Interactive Connectivity Establishment (ICE) protocol that enables
   ICE agents to begin connectivity checks while they are still
   gathering candidates, by incrementally exchanging candidates over
   time instead of all at once.  This method can considerably accelerate
   the process of establishing a communication session.

Status of This Memo

   This Internet-Draft is submitted in full conformance with the
   provisions of BCP 78 and BCP 79.

   Internet-Drafts are working documents of the Internet Engineering
   Task Force (IETF).  Note that other groups may also distribute
   working documents as Internet-Drafts.  The list of current Internet-
   Drafts is at http://datatracker.ietf.org/drafts/current/.

   Internet-Drafts are draft documents valid for a maximum of six months
   and may be updated, replaced, or obsoleted by other documents at any
   time.  It is inappropriate to use Internet-Drafts as reference
   material or to cite them other than as "work in progress."

   This Internet-Draft will expire on October 17, 2018.

Copyright Notice

   Copyright (c) 2018 IETF Trust and the persons identified as the
   document authors.  All rights reserved.

   This document is subject to BCP 78 and the IETF Trust's Legal
   Provisions Relating to IETF Documents



Ivov, et al.            Expires October 17, 2018                [Page 1]

Internet-Draft                 Trickle ICE                    April 2018


   (http://trustee.ietf.org/license-info) in effect on the date of
   publication of this document.  Please review these documents
   carefully, as they describe your rights and restrictions with respect
   to this document.  Code Components extracted from this document must
   include Simplified BSD License text as described in Section 4.e of
   the Trust Legal Provisions and are provided without warranty as
   described in the Simplified BSD License.

Table of Contents

   1.  Introduction  . . . . . . . . . . . . . . . . . . . . . . . .   3
   2.  Terminology . . . . . . . . . . . . . . . . . . . . . . . . .   5
   3.  Determining Support for Trickle ICE . . . . . . . . . . . . .   6
   4.  Generating the Initial ICE Description  . . . . . . . . . . .   7
   5.  Handling the Initial ICE Description and Generating the
       Initial ICE Response  . . . . . . . . . . . . . . . . . . . .   7
   6.  Handling the Initial ICE Response . . . . . . . . . . . . . .   8
   7.  Forming Check Lists . . . . . . . . . . . . . . . . . . . . .   8
   8.  Performing Connectivity Checks  . . . . . . . . . . . . . . .   8
   9.  Gathering and Conveying Newly Gathered Local Candidates . . .   9
   10. Pairing Newly Gathered Local Candidates . . . . . . . . . . .  10
   11. Receiving Trickled Candidates . . . . . . . . . . . . . . . .  11
   12. Inserting Trickled Candidate Pairs into a Check List  . . . .  12
   13. Generating an End-of-Candidates Indication  . . . . . . . . .  16
   14. Receiving an End-of-Candidates Indication . . . . . . . . . .  17
   15. Subsequent Exchanges and ICE Restarts . . . . . . . . . . . .  18
   16. Half Trickle  . . . . . . . . . . . . . . . . . . . . . . . .  18
   17. Preserving Candidate Order while Trickling  . . . . . . . . .  19
   18. Requirements for Using Protocols  . . . . . . . . . . . . . .  20
   19. IANA Considerations . . . . . . . . . . . . . . . . . . . . .  21
   20. Security Considerations . . . . . . . . . . . . . . . . . . .  21
   21. Acknowledgements  . . . . . . . . . . . . . . . . . . . . . .  21
   22. References  . . . . . . . . . . . . . . . . . . . . . . . . .  22
     22.1.  Normative References . . . . . . . . . . . . . . . . . .  22
     22.2.  Informative References . . . . . . . . . . . . . . . . .  22
   Appendix A.  Interaction with Regular ICE . . . . . . . . . . . .  23
   Appendix B.  Interaction with ICE Lite  . . . . . . . . . . . . .  25
   Appendix C.  Changes from Earlier Versions  . . . . . . . . . . .  26
     C.1.  Changes from draft-ietf-ice-trickle-20  . . . . . . . . .  26
     C.2.  Changes from draft-ietf-ice-trickle-19  . . . . . . . . .  26
     C.3.  Changes from draft-ietf-ice-trickle-18  . . . . . . . . .  26
     C.4.  Changes from draft-ietf-ice-trickle-17  . . . . . . . . .  27
     C.5.  Changes from draft-ietf-ice-trickle-16  . . . . . . . . .  27
     C.6.  Changes from draft-ietf-ice-trickle-15  . . . . . . . . .  27
     C.7.  Changes from draft-ietf-ice-trickle-14  . . . . . . . . .  27
     C.8.  Changes from draft-ietf-ice-trickle-13  . . . . . . . . .  27
     C.9.  Changes from draft-ietf-ice-trickle-12  . . . . . . . . .  27
     C.10. Changes from draft-ietf-ice-trickle-11  . . . . . . . . .  28



Ivov, et al.            Expires October 17, 2018                [Page 2]

Internet-Draft                 Trickle ICE                    April 2018


     C.11. Changes from draft-ietf-ice-trickle-10  . . . . . . . . .  28
     C.12. Changes from draft-ietf-ice-trickle-09  . . . . . . . . .  28
     C.13. Changes from draft-ietf-ice-trickle-08  . . . . . . . . .  28
     C.14. Changes from draft-ietf-ice-trickle-07  . . . . . . . . .  28
     C.15. Changes from draft-ietf-ice-trickle-06  . . . . . . . . .  28
     C.16. Changes from draft-ietf-ice-trickle-05  . . . . . . . . .  28
     C.17. Changes from draft-ietf-ice-trickle-04  . . . . . . . . .  29
     C.18. Changes from draft-ietf-ice-trickle-03  . . . . . . . . .  29
     C.19. Changes from draft-ietf-ice-trickle-02  . . . . . . . . .  29
     C.20. Changes from draft-ietf-ice-trickle-01  . . . . . . . . .  29
     C.21. Changes from draft-ietf-ice-trickle-00  . . . . . . . . .  29
     C.22. Changes from draft-mmusic-trickle-ice-02  . . . . . . . .  29
     C.23. Changes from draft-ivov-01 and draft-mmusic-00  . . . . .  30
     C.24. Changes from draft-ivov-00  . . . . . . . . . . . . . . .  30
     C.25. Changes from draft-rescorla-01  . . . . . . . . . . . . .  31
     C.26. Changes from draft-rescorla-00  . . . . . . . . . . . . .  32
   Authors' Addresses  . . . . . . . . . . . . . . . . . . . . . . .  32

1.  Introduction

   The Interactive Connectivity Establishment (ICE) protocol
   [rfc5245bis] describes how an ICE agent gathers candidates, exchanges
   candidates with a peer ICE agent, and creates candidate pairs.  Once
   the pairs have been gathered, the ICE agent will perform connectivity
   checks, and eventually nominate and select pairs that will be used
   for sending and receiving data within a communication session.

   Following the procedures in [rfc5245bis] can lead to somewhat lengthy
   establishment times for communication sessions, because candidate
   gathering often involves querying STUN servers [RFC5389] and
   allocating relayed candidates using TURN servers [RFC5766].  Although
   many ICE procedures can be completed in parallel, the pacing
   requirements from [rfc5245bis] still need to be followed.

   This document defines "Trickle ICE", a supplementary mode of ICE
   operation in which candidates can be exchanged incrementally as soon
   as they become available (and simultaneously with the gathering of
   other candidates).  Connectivity checks can also start as soon as
   candidate pairs have been created.  Because Trickle ICE enables
   candidate gathering and connectivity checks to be done in parallel,
   the method can considerably accelerate the process of establishing a
   communication session.

   This document also defines how to discover support for Trickle ICE,
   how the procedures in [rfc5245bis] are modified or supplemented when
   using Trickle ICE, and how a Trickle ICE agent can interoperate with
   an ICE agent compliant to [rfc5245bis].




Ivov, et al.            Expires October 17, 2018                [Page 3]

Internet-Draft                 Trickle ICE                    April 2018


   This document does not define any protocol-specific usage of Trickle
   ICE.  Instead, protocol-specific details for Trickle ICE are defined
   in separate usage documents.  Examples of such documents are
   [I-D.ietf-mmusic-trickle-ice-sip] (which defines usage with the
   Session Initiation Protocol (SIP) [RFC3261] and the Session
   Description Protocol [RFC3261]) and [XEP-0176] (which defines usage
   with XMPP [RFC6120]).  However, some of the examples in the document
   use SDP and the offer/answer model [RFC3264] to explain the
   underlying concepts.

   The following diagram illustrates a successful Trickle ICE exchange
   with a using protocol that follows the offer/answer model:


           Alice                                            Bob
             |                     Offer                     |
             |---------------------------------------------->|
             |            Additional Candidates              |
             |---------------------------------------------->|
             |                     Answer                    |
             |<----------------------------------------------|
             |            Additional Candidates              |
             |<----------------------------------------------|
             | Additional Candidates and Connectivity Checks |
             |<--------------------------------------------->|
             |<========== CONNECTION ESTABLISHED ===========>|



                              Figure 1: Flow

   The main body of this document is structured to describe the behavior
   of Trickle ICE agents in roughly the order of operations and
   interactions during an ICE session:

   1.  Determining support for trickle ICE

   2.  Generating the initial ICE description

   3.  Handling the initial ICE description and generating the initial
       ICE response

   4.  Handling the initial ICE response

   5.  Forming check lists, pruning candidates, performing connectivity
       checks, etc.





Ivov, et al.            Expires October 17, 2018                [Page 4]

Internet-Draft                 Trickle ICE                    April 2018


   6.  Gathering and conveying candidates after the initial ICE
       description and response

   7.  Handling inbound trickled candidates

   8.  Generating and handling the end-of-candidates indication

   9.  Handling ICE restarts

   There is quite a bit of operational experience with the technique
   behind Trickle ICE, going back as far as 2005 (when the XMPP Jingle
   extension defined a "dribble mode" as specified in [XEP-0176]); this
   document incorporates feedback from those who have implemented and
   deployed the technique over the years.

2.  Terminology

   The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
   "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
   document are to be interpreted as described in [RFC2119].

   This specification makes use of all terminology defined for
   Interactive Connectivity Establishment in [rfc5245bis].  In addition,
   it defines the following terms:

   Full Trickle:  The typical mode of operation for Trickle ICE agents,
      in which the initial ICE description can include any number of
      candidates (even zero candidates) and does not need to include a
      full generation of candidates as in half trickle.

   Generation:  All of the candidates conveyed within an ICE session.

   Half Trickle:  A Trickle ICE mode of operation in which the initiator
      gathers a full generation of candidates strictly before creating
      and conveying the initial ICE description.  Once conveyed, this
      candidate information can be processed by regular ICE agents,
      which do not require support for Trickle ICE.  It also allows
      Trickle ICE capable responders to still gather candidates and
      perform connectivity checks in a non-blocking way, thus providing
      roughly "half" the advantages of Trickle ICE.  The half trickle
      mechanism is mostly meant for use when the responder's support for
      Trickle ICE cannot be confirmed prior to conveying the initial ICE
      description.

   ICE Description:  Any attributes related to the ICE session (not
      candidates) required to configure an ICE agent.  These include but
      are not limited to the username fragment, password, and other
      attributes.



Ivov, et al.            Expires October 17, 2018                [Page 5]

Internet-Draft                 Trickle ICE                    April 2018


   Trickled Candidates:  Candidates that a Trickle ICE agent conveys
      after conveying the initial ICE description or responding to the
      initial ICE description, but within the same ICE session.
      Trickled candidates can be conveyed in parallel with candidate
      gathering and connectivity checks.

   Trickling:  The act of incrementally conveying trickled candidates.

   Empty Check List:  A check list that initially does not contain any
      candidate pairs because they will be incrementally added as they
      are trickled.  (This scenario does not arise with a regular ICE
      agent, because all candidate pairs are known when the agent
      creates the check list set).

3.  Determining Support for Trickle ICE

   To fully support Trickle ICE, using protocols SHOULD incorporate one
   of the following mechanisms so that implementations can determine
   whether Trickle ICE is supported:

   1.  Provide a capabilities discovery method so that agents can verify
       support of Trickle ICE prior to initiating a session (XMPP's
       Service Discovery [XEP-0030] is one such mechanism).

   2.  Make support for Trickle ICE mandatory so that user agents can
       assume support.

   If a using protocol does not provide a method of determining ahead of
   time whether Trickle ICE is supported, agents can make use of the
   half trickle procedure described in Section 16.

   Prior to conveying the initial ICE description, agents that implement
   using protocols that support capabilities discovery can attempt to
   verify whether or not the remote party supports Trickle ICE.  If an
   agent determines that the remote party does not support Trickle ICE,
   it MUST fall back to using regular ICE or abandon the entire session.

   Even if a using protocol does not include a capabilities discovery
   method, a user agent can provide an indication within the ICE
   description that it supports Trickle ICE by communicating an ICE
   option of 'trickle'.  This token MUST be provided either at the
   session level or, if at the data stream level, for every data stream
   (an agent MUST NOT specify Trickle ICE support for some data streams
   but not others).  Note: The encoding of the 'trickle' ICE option, and
   the message(s) used to carry it to the peer, are protocol specific;
   for instance, the encoding for the Session Description Protocol (SDP)
   [RFC4566] is defined in [I-D.ietf-mmusic-trickle-ice-sip].




Ivov, et al.            Expires October 17, 2018                [Page 6]

Internet-Draft                 Trickle ICE                    April 2018


   Dedicated discovery semantics and half trickle are needed only prior
   to initiation of an ICE session.  After an ICE session is established
   and Trickle ICE support is confirmed for both parties, either agent
   can use full trickle for subsequent exchanges (see also Section 15).

4.  Generating the Initial ICE Description

   An ICE agent can start gathering candidates as soon as it has an
   indication that communication is imminent (e.g., a user interface cue
   or an explicit request to initiate a communication session).  Unlike
   in regular ICE, in Trickle ICE implementations do not need to gather
   candidates in a blocking manner.  Therefore, unless half trickle is
   being used, the user experience is improved if the initiating agent
   generates and transmits its initial ICE description as early as
   possible (thus enabling the remote party to start gathering and
   trickling candidates).

   An initiator MAY include any mix of candidates when conveying the
   initial ICE description.  This includes the possibility of conveying
   all the candidates the initiator plans to use (as in half trickle),
   conveying only a publicly-reachable IP address (e.g., a candidate at
   a data relay that is known to not be behind a firewall), or conveying
   no candidates at all (in which case the initiator can obtain the
   responder's initial candidate list sooner and the responder can begin
   candidate gathering more quickly).

   For candidates included in the initial ICE description, the methods
   for calculating priorities and foundations, determining redundancy of
   candidates, and the like work just as in regular ICE [rfc5245bis].

5.  Handling the Initial ICE Description and Generating the Initial ICE
    Response

   When a responder receives the initial ICE description, it will first
   check if the ICE description or initiator indicates support for
   Trickle ICE as explained in Section 3.  If not, the responder MUST
   process the initial ICE description according to regular ICE
   procedures [rfc5245bis] (or, if no ICE support is detected at all,
   according to relevant processing rules for the using protocol, such
   as offer/answer processing rules [RFC3264]).  However, if support for
   Trickle ICE is confirmed, a responder will automatically assume
   support for regular ICE as well.

   If the initial ICE description indicates support for Trickle ICE, the
   responder will determine its role and start gathering and
   prioritizing candidates; while doing so, it will also respond by
   conveying an initial ICE response, so that both the initiator and the
   responder can form check lists and begin connectivity checks.



Ivov, et al.            Expires October 17, 2018                [Page 7]

Internet-Draft                 Trickle ICE                    April 2018


   A responder can respond to the initial ICE description at any point
   while gathering candidates.  The initial ICE response MAY contain any
   set of candidates, including all candidates or no candidates.  (The
   benefit of including no candidates is to convey the initial ICE
   response as quickly as possible, so that both parties can consider
   the ICE session to be under active negotiation as soon as possible.)

   As noted in Section 3, in using protocols that use SDP the initial
   ICE response can indicate support for Trickle ICE by including a
   token of "trickle" in the ice-options attribute.

6.  Handling the Initial ICE Response

   When processing the initial ICE response, the initiator follows
   regular ICE procedures to determine its role, after which it forms
   check lists (Section 7) and performs connectivity checks (Section 8).

7.  Forming Check Lists

   According to regular ICE procedures [rfc5245bis], in order for
   candidate pairing to be possible and for redundant candidates to be
   pruned, the candidates would need to be provided in the initial ICE
   description and initial ICE response.  By contrast, under Trickle ICE
   check lists can be empty until candidates are conveyed or received.
   Therefore a Trickle ICE agent handles check list formation and
   candidate pairing in a slightly different way than a regular ICE
   agent: the agent still forms the check lists, but it populates a
   given check list only after it actually has candidate pairs for that
   check list.  Every check list is initially placed in the Running
   state, even if the check list is empty (this is consistent with
   Section 6.1.2.1 of [rfc5245bis]).

8.  Performing Connectivity Checks

   As specified in [rfc5245bis], whenever timer Ta fires, only check
   lists in the Running state will be picked when scheduling
   connectivity checks for candidate pairs.  Therefore, a Trickle ICE
   agent MUST keep each check list in the Running state as long as it
   expects candidate pairs to be incrementally added to the check list.
   After that, the check list state is set according to the procedures
   in [rfc5245bis].

   Whenever timer Ta fires and an empty check list is picked, no action
   is performed for the list.  Without waiting for timer Ta to expire
   again, the agent selects the next check list in the Running state, in
   accordance with Section 6.1.4.2 of [rfc5245bis].





Ivov, et al.            Expires October 17, 2018                [Page 8]

Internet-Draft                 Trickle ICE                    April 2018


   Section 7.2.5.3.3 of [rfc5245bis] requires that agents update check
   lists and timer states upon completing a connectivity check
   transaction.  During such an update, regular ICE agents would set the
   state of a check list to Failed if both of the following two
   conditions are satisfied:

   o  all of the pairs in the check list are either in the Failed state
      or Succeeded state; and

   o  there is not a pair in the valid list for each component of the
      data stream.

   With Trickle ICE, the above situation would often occur when
   candidate gathering and trickling are still in progress, even though
   it is quite possible that future checks will succeed.  For this
   reason, Trickle ICE agents add the following conditions to the above
   list:

   o  all candidate gathering has completed and the agent is not
      expecting to discover any new local candidates; and

   o  the remote agent has conveyed an end-of-candidates indication for
      that check list as described in Section 13.

9.  Gathering and Conveying Newly Gathered Local Candidates

   After Trickle ICE agents have conveyed initial ICE descriptions and
   initial ICE responses, they will most likely continue gathering new
   local candidates as STUN, TURN, and other non-host candidate
   gathering mechanisms begin to yield results.  Whenever an agent
   discovers such a new candidate it will compute its priority, type,
   foundation, and component ID according to regular ICE procedures.

   The new candidate is then checked for redundancy against the existing
   list of local candidates.  If its transport address and base match
   those of an existing candidate, it will be considered redundant and
   will be ignored.  This would often happen for server reflexive
   candidates that match the host addresses they were obtained from
   (e.g., when the latter are public IPv4 addresses).  Contrary to
   regular ICE, Trickle ICE agents will consider the new candidate
   redundant regardless of its priority.

   Next the agent "trickles" the newly discovered candidate(s) to the
   remote agent.  The actual delivery of the new candidates is handled
   by a using protocol such as SIP or XMPP.  Trickle ICE imposes no
   restrictions on the way this is done (e.g., some using protocols
   might choose not to trickle updates for server reflexive candidates
   and instead rely on the discovery of peer reflexive ones).



Ivov, et al.            Expires October 17, 2018                [Page 9]

Internet-Draft                 Trickle ICE                    April 2018


   When candidates are trickled, the using protocol MUST deliver each
   candidate (and any end-of-candidates indication as described in
   Section 13) to the receiving Trickle ICE implementation exactly once
   and in the same order it was conveyed.  If the using protocol
   provides any candidate retransmissions, they need to be hidden from
   the ICE implementation.

   Also, candidate trickling needs to be correlated to a specific ICE
   session, so that if there is an ICE restart, any delayed updates for
   a previous session can be recognized as such and ignored by the
   receiving party.  For example, using protocols that signal candidates
   via SDP might include a Username Fragment value in the corresponding
   a=candidate line, such as:


     a=candidate:1 1 UDP 2130706431 2001:db8::1 5000 typ host ufrag 8hhY


   Or, as another example, WebRTC implementations might include a
   Username Fragment in the JavaScript objects that represent
   candidates.

   Note: The using protocol needs to provide a mechanism for both
   parties to indicate and agree on the ICE session in force (as
   identified by the Username Fragment and Password combination) so that
   they have a consistent view of which candidates are to be paired.
   This is especially important in the case of ICE restarts (see
   Section 15).

   Note: A using protocol might prefer not to trickle server reflexive
   candidates to entities that are known to be publicly accessible and
   where sending a direct STUN binding request is likely to reach the
   destination faster than the trickle update that travels through the
   signaling path.

10.  Pairing Newly Gathered Local Candidates

   As a Trickle ICE agent gathers local candidates, it needs to form
   candidate pairs; this works as described in the ICE specification
   [rfc5245bis], with the following provisos:

   1.  A Trickle ICE agent MUST NOT pair a local candidate until it has
       been trickled to the remote party.

   2.  Once the agent has conveyed the local candidate to the remote
       party, the agent checks if any remote candidates are currently
       known for this same stream and component.  If not, the agent




Ivov, et al.            Expires October 17, 2018               [Page 10]

Internet-Draft                 Trickle ICE                    April 2018


       merely adds the new candidate to the list of local candidates
       (without pairing it).

   3.  Otherwise, if the agent has already learned of one or more remote
       candidates for this stream and component, it attempts to pair the
       new local candidate as described in the ICE specification
       [rfc5245bis].

   4.  If a newly formed pair has a local candidate whose type is server
       reflexive, the agent MUST replace the local candidate with its
       base before completing the relevant redundancy tests.

   5.  The agent prunes redundant pairs by following the rules in
       Section 6.1.2.4 of [rfc5245bis], but checks existing pairs only
       if they have a state of Waiting or Frozen; this avoids removal of
       pairs for which connectivity checks are in flight (a state of In-
       Progress) or for which connectivity checks have already yielded a
       definitive result (a state of Succeeded or Failed).

   6.  If after the relevant redundancy tests the check list where the
       pair is to be added already contains the maximum number of
       candidate pairs (100 by default as per [rfc5245bis]), the agent
       SHOULD discard any pairs in the Failed state to make room for the
       new pair.  If there are no such pairs, the agent SHOULD discard a
       pair with a lower priority than the new pair in order to make
       room for the new pair, until the number of pairs is equal to the
       maximum number of pairs.  This processing is consistent with
       Section 6.1.2.5 of [rfc5245bis].

11.  Receiving Trickled Candidates

   At any time during an ICE session, a Trickle ICE agent might receive
   new candidates from the remote agent, from which it will attempt to
   form a candidate pair; this works as described in the ICE
   specification [rfc5245bis], with the following provisos:

   1.  The agent checks if any local candidates are currently known for
       this same stream and component.  If not, the agent merely adds
       the new candidate to the list of remote candidates (without
       pairing it).

   2.  Otherwise, if the agent has already gathered one or more local
       candidates for this stream and component, it attempts to pair the
       new remote candidate as described in the ICE specification
       [rfc5245bis].






Ivov, et al.            Expires October 17, 2018               [Page 11]

Internet-Draft                 Trickle ICE                    April 2018


   3.  If a newly formed pair has a local candidate whose type is server
       reflexive, the agent MUST replace the local candidate with its
       base before completing the redundancy check in the next step.

   4.  The agent prunes redundant pairs as described below, but checks
       existing pairs only if they have a state of Waiting or Frozen;
       this avoids removal of pairs for which connectivity checks are in
       flight (a state of In-Progress) or for which connectivity checks
       have already yielded a definitive result (a state of Succeeded or
       Failed).

       A.  If the agent finds a redundancy between two pairs and one of
           those pairs contains a newly received remote candidate whose
           type is peer reflexive, the agent SHOULD discard the pair
           containing that candidate, set the priority of the existing
           pair to the priority of the discarded pair, and re-sort the
           check list.  (This policy helps to eliminate problems with
           remote peer reflexive candidates for which a STUN binding
           request is received before signaling of the candidate is
           trickled to the receiving agent, such as a different view of
           pair priorities between the local agent and the remote agent,
           since the same candidate could be perceived as peer reflexive
           by one agent and as server reflexive by the other agent.)

       B.  The agent then applies the rules defined in Section 6.1.2.4
           of [rfc5245bis].

   5.  If after the relevant redundancy tests the check list where the
       pair is to be added already contains the maximum number of
       candidate pairs (100 by default as per [rfc5245bis]), the agent
       SHOULD discard any pairs in the Failed state to make room for the
       new pair.  If there are no such pairs, the agent SHOULD discard a
       pair with a lower priority than the new pair in order to make
       room for the new pair, until the number of pairs is equal to the
       maximum number of pairs.  This processing is consistent with
       Section 6.1.2.5 of [rfc5245bis].

12.  Inserting Trickled Candidate Pairs into a Check List

   After a local agent has trickled a candidate and formed a candidate
   pair from that local candidate (Section 9), or after a remote agent
   has received a trickled candidate and formed a candidate pair from
   that remote candidate (Section 11), a Trickle ICE agent adds the new
   candidate pair to a check list as defined in this section.

   As an aid to understanding the procedures defined in this section,
   consider the following tabular representation of all check lists in




Ivov, et al.            Expires October 17, 2018               [Page 12]

Internet-Draft                 Trickle ICE                    April 2018


   an agent (note that initially for one of the foundations, i.e., f5,
   there are no candidate pairs):


   +-----------------+------+------+------+------+------+
   |                 |  f1  |  f2  |  f3  |  f4  |  f5  |
   +-----------------+------+------+------+------+------+
   | s1 (Audio.RTP)  |  F   |  F   |  F   |      |      |
   +-----------------+------+------+------+------+------+
   | s2 (Audio.RTCP) |  F   |  F   |  F   |  F   |      |
   +-----------------+------+------+------+------+------+
   | s3 (Video.RTP)  |  F   |      |      |      |      |
   +-----------------+------+------+------+------+------+
   | s4 (Video.RTCP) |  F   |      |      |      |      |
   +-----------------+------+------+------+------+------+


                   Figure 2: Example of Check List State

   Each row in the table represents a component for a given data stream
   (e.g., s1 and s2 might be the RTP and RTCP components for audio) and
   thus a single check list in the check list set.  Each column
   represents one foundation.  Each cell represents one candidate pair.
   In the tables shown in this section, "F" stands for "frozen", "W"
   stands for "waiting", and "S" stands for "succeeded"; in addition,
   "^^" is used to notate newly-added candidate pairs.

   When an agent commences ICE processing, in accordance with
   Section 6.1.2.6 of [rfc5245bis], for each foundation it will unfreeze
   the pair with the lowest component ID and, if the component IDs are
   equal, with the highest priority (this is the topmost candidate pair
   in every column).  This initial state is shown in the following
   table.


















Ivov, et al.            Expires October 17, 2018               [Page 13]

Internet-Draft                 Trickle ICE                    April 2018


   +-----------------+------+------+------+------+------+
   |                 |  f1  |  f2  |  f3  |  f4  |  f5  |
   +-----------------+------+------+------+------+------+
   | s1 (Audio.RTP)  |  W   |  W   |  W   |      |      |
   +-----------------+------+------+------+------+------+
   | s2 (Audio.RTCP) |  F   |  F   |  F   |  W   |      |
   +-----------------+------+------+------+------+------+
   | s3 (Video.RTP)  |  F   |      |      |      |      |
   +-----------------+------+------+------+------+------+
   | s4 (Video.RTCP) |  F   |      |      |      |      |
   +-----------------+------+------+------+------+------+


                    Figure 3: Initial Check List State

   Then, as the checks proceed (see Section 7.2.5.4 of [rfc5245bis]),
   for each pair that enters the Succeeded state (denoted here by "S"),
   the agent will unfreeze all pairs for all data streams with the same
   foundation (e.g., if the pair in column 1, row 1 succeeds then the
   agent will unfreeze the pair in column 1, rows 2, 3, and 4).


   +-----------------+------+------+------+------+------+
   |                 |  f1  |  f2  |  f3  |  f4  |  f5  |
   +-----------------+------+------+------+------+------+
   | s1 (Audio.RTP)  |  S   |  W   |  W   |      |      |
   +-----------------+------+------+------+------+------+
   | s2 (Audio.RTCP) |  W   |  F   |  F   |  W   |      |
   +-----------------+------+------+------+------+------+
   | s3 (Video.RTP)  |  W   |      |      |      |      |
   +-----------------+------+------+------+------+------+
   | s4 (Video.RTCP) |  W   |      |      |      |      |
   +-----------------+------+------+------+------+------+


         Figure 4: Check List State with Succeeded Candidate Pair

   Trickle ICE preserves all of these rules as they apply to "static"
   check list sets.  This implies that if a Trickle ICE agent were to
   begin connectivity checks with all of its pairs already present, the
   way that pair states change is indistinguishable from that of a
   regular ICE agent.

   Of course, the major difference with Trickle ICE is that check list
   sets can be dynamically updated because candidates can arrive after
   connectivity checks have started.  When this happens, an agent sets
   the state of the newly formed pair as described below.




Ivov, et al.            Expires October 17, 2018               [Page 14]

Internet-Draft                 Trickle ICE                    April 2018


   Rule 1: If the newly formed pair has the lowest component ID and, if
   the component IDs are equal, the highest priority of any candidate
   pair for this foundation (i.e., if it is the topmost pair in the
   column), set the state to Waiting.  For example, this would be the
   case if the newly formed pair were placed in column 5, row 1.  This
   rule is consistent with Section 6.1.2.6 of [rfc5245bis].


   +-----------------+------+------+------+------+------+
   |                 |  f1  |  f2  |  f3  |  f4  |  f5  |
   +-----------------+------+------+------+------+------+
   | s1 (Audio.RTP)  |  S   |  W   |  W   |      | ^W^  |
   +-----------------+------+------+------+------+------+
   | s2 (Audio.RTCP) |  W   |  F   |  F   |  W   |      |
   +-----------------+------+------+------+------+------+
   | s3 (Video.RTP)  |  W   |      |      |      |      |
   +-----------------+------+------+------+------+------+
   | s4 (Video.RTCP) |  W   |      |      |      |      |
   +-----------------+------+------+------+------+------+


         Figure 5: Check List State with Newly Formed Pair, Rule 1

   Rule 2: If there is at least one pair in the Succeeded state for this
   foundation, set the state to Waiting.  For example, this would be the
   case if the pair in column 5, row 1 succeeded and the newly formed
   pair were placed in column 5, row 2.  This rule is consistent with
   Section 7.2.5.3.3 of [rfc5245bis].


   +-----------------+------+------+------+------+------+
   |                 |  f1  |  f2  |  f3  |  f4  |  f5  |
   +-----------------+------+------+------+------+------+
   | s1 (Audio.RTP)  |  S   |  W   |  W   |      |  S   |
   +-----------------+------+------+------+------+------+
   | s2 (Audio.RTCP) |  W   |  F   |  F   |  W   | ^W^  |
   +-----------------+------+------+------+------+------+
   | s3 (Video.RTP)  |  W   |      |      |      |      |
   +-----------------+------+------+------+------+------+
   | s4 (Video.RTCP) |  W   |      |      |      |      |
   +-----------------+------+------+------+------+------+


         Figure 6: Check List State with Newly Formed Pair, Rule 2

   Rule 3: In all other cases, set the state to Frozen.  For example,
   this would be the case if the newly formed pair were placed in column
   3, row 3.



Ivov, et al.            Expires October 17, 2018               [Page 15]

Internet-Draft                 Trickle ICE                    April 2018


   +-----------------+------+------+------+------+------+
   |                 |  f1  |  f2  |  f3  |  f4  |  f5  |
   +-----------------+------+------+------+------+------+
   | s1 (Audio.RTP)  |  S   |  W   |  W   |      |  S   |
   +-----------------+------+------+------+------+------+
   | s2 (Audio.RTCP) |  W   |  F   |  F   |  W   |  W   |
   +-----------------+------+------+------+------+------+
   | s3 (Video.RTP)  |  W   |      | ^F^  |      |      |
   +-----------------+------+------+------+------+------+
   | s4 (Video.RTCP) |  W   |      |      |      |      |
   +-----------------+------+------+------+------+------+


         Figure 7: Check List State with Newly Formed Pair, Rule 3

13.  Generating an End-of-Candidates Indication

   Once all candidate gathering is completed or expires for an ICE
   session associated with a specific data stream, the agent will
   generate an "end-of-candidates" indication for that session and
   convey it to the remote agent via the signaling channel.  Although
   the exact form of the indication depends on the using protocol, the
   indication MUST specify the generation (Username Fragment and
   Password combination) so that an agent can correlate the end-of-
   candidates indication with a particular ICE session.  The indication
   can be conveyed in the following ways:

   o  As part of an initiation request (which would typically be the
      case with the initial ICE description for half trickle)

   o  Along with the last candidate an agent can send for a stream

   o  As a standalone notification (e.g., after STUN Binding requests or
      TURN Allocate requests to a server time out and the agent is no
      longer actively gathering candidates)

   Conveying an end-of-candidates indication in a timely manner is
   important in order to avoid ambiguities and speed up the conclusion
   of ICE processing.  In particular:

   o  A controlled Trickle ICE agent SHOULD convey an end-of-candidates
      indication after it has completed gathering for a data stream,
      unless ICE processing terminates before the agent has had a chance
      to complete gathering.

   o  A controlling agent MAY conclude ICE processing prior to conveying
      end-of-candidates indications for all streams.  However, it is
      RECOMMENDED for a controlling agent to convey end-of-candidates



Ivov, et al.            Expires October 17, 2018               [Page 16]

Internet-Draft                 Trickle ICE                    April 2018


      indications whenever possible for the sake of consistency and to
      keep middleboxes and controlled agents up-to-date on the state of
      ICE processing.

   When conveying an end-of-candidates indication during trickling
   (rather than as a part of the initial ICE description or a response
   thereto), it is the responsibility of the using protocol to define
   methods for associating the indication with one or more specific data
   streams.

   An agent MAY also choose to generate an end-of-candidates indication
   before candidate gathering has actually completed, if the agent
   determines that gathering has continued for more than an acceptable
   period of time.  However, an agent MUST NOT convey any more
   candidates after it has conveyed an end-of-candidates indication.

   When performing half trickle, an agent SHOULD convey an end-of-
   candidates indication together with its initial ICE description
   unless it is planning to potentially trickle additional candidates
   (e.g., in case the remote party turns out to support Trickle ICE).

   After an agent conveys the end-of-candidates indication, it will
   update the state of the corresponding check list as explained in
   Section 8.  Past that point, an agent MUST NOT trickle any new
   candidates within this ICE session.  Therefore, adding new candidates
   to the negotiation is possible only through an ICE restart (see
   Section 15).

   This specification does not override regular ICE semantics for
   concluding ICE processing.  Therefore, even if end-of-candidates
   indications are conveyed, an agent will still need to go through pair
   nomination.  Also, if pairs have been nominated for components and
   data streams, ICE processing MAY still conclude even if end-of-
   candidates indications have not been received for all streams.  In
   all cases, an agent MUST NOT trickle any new candidates within an ICE
   session after nomination of a candidate pair as described in
   Section 8.1.1 of [rfc5245bis].

14.  Receiving an End-of-Candidates Indication

   Receiving an end-of-candidates indication enables an agent to update
   check list states and, in case valid pairs do not exist for every
   component in every data stream, determine that ICE processing has
   failed.  It also enables an agent to speed up the conclusion of ICE
   processing when a candidate pair has been validated but it involves
   the use of lower-preference transports such as TURN.  In such
   situations, an implementation MAY choose to wait and see if higher-
   priority candidates are received; in this case the end-of-candidates



Ivov, et al.            Expires October 17, 2018               [Page 17]

Internet-Draft                 Trickle ICE                    April 2018


   indication provides a notification that such candidates are not
   forthcoming.

   When an agent receives an end-of-candidates indication for a specific
   data stream, it will update the state of the relevant check list as
   per Section 8 (which might lead to some check lists being marked as
   Failed).  If the check list is still in the Running state after the
   update, the agent will persist the fact that an end-of-candidates
   indication has been received and take it into account in future
   updates to the check list.

   After an agent has received an end-of-candidates indication, it MUST
   ignore any newly received candidates for that data stream or data
   session.

15.  Subsequent Exchanges and ICE Restarts

   Before conveying an end-of-candidates indication, either agent MAY
   convey subsequent candidate information at any time allowed by the
   using protocol.  When this happens, agents will use [rfc5245bis]
   semantics (e.g., checking of the Username Fragment and Password
   combination) to determine whether or not the new candidate
   information requires an ICE restart.

   If an ICE restart occurs, the agents can assume that Trickle ICE is
   still supported if support was determined previously, and thus can
   engage in Trickle ICE behavior as they would in an initial exchange
   of ICE descriptions where support was determined through a
   capabilities discovery method.

16.  Half Trickle

   In half trickle, the initiator conveys the initial ICE description
   with a usable but not necessarily full generation of candidates.
   This ensures that the ICE description can be processed by a regular
   ICE responder and is mostly meant for use in cases where support for
   Trickle ICE cannot be confirmed prior to conveying the initial ICE
   description.  The initial ICE description indicates support for
   Trickle ICE, so that the responder can respond with something less
   than a full generation of candidates and then trickle the rest.  The
   initial ICE description for half trickle can contain an end-of-
   candidates indication, although this is not mandatory because if
   trickle support is confirmed then the initiator can choose to trickle
   additional candidates before it conveys an end-of-candidates
   indication.

   The half trickle mechanism can be used in cases where there is no way
   for an agent to verify in advance whether a remote party supports



Ivov, et al.            Expires October 17, 2018               [Page 18]

Internet-Draft                 Trickle ICE                    April 2018


   Trickle ICE.  Because the initial ICE description contain a full
   generation of candidates, it can thus be handled by a regular ICE
   agent, while still allowing a Trickle ICE agent to use the
   optimization defined in this specification.  This prevents
   negotiation from failing in the former case while still giving
   roughly half the Trickle ICE benefits in the latter.

   Use of half trickle is only necessary during an initial exchange of
   ICE descriptions.  After both parties have received an ICE
   description from their peer, they can each reliably determine Trickle
   ICE support and use it for all subsequent exchanges (see Section 15).

   In some instances, using half trickle might bring more than just half
   the improvement in terms of user experience.  This can happen when an
   agent starts gathering candidates upon user interface cues that the
   user will soon be initiating an interaction, such as activity on a
   keypad or the phone going off hook.  This would mean that some or all
   of the candidate gathering could be completed before the agent
   actually needs to convey the candidate information.  Because the
   responder will be able to trickle candidates, both agents will be
   able to start connectivity checks and complete ICE processing earlier
   than with regular ICE and potentially even as early as with full
   trickle.

   However, such anticipation is not always possible.  For example, a
   multipurpose user agent or a WebRTC web page where communication is a
   non-central feature (e.g., calling a support line in case of a
   problem with the main features) would not necessarily have a way of
   distinguishing between call intentions and other user activity.  In
   such cases, using full trickle is most likely to result in an ideal
   user experience.  Even so, using half trickle would be an improvement
   over regular ICE because it would result in a better experience for
   responders.

17.  Preserving Candidate Order while Trickling

   One important aspect of regular ICE is that connectivity checks for a
   specific foundation and component are attempted simultaneously by
   both agents, so that any firewalls or NATs fronting the agents would
   whitelist both endpoints and allow all except for the first
   ("suicide") packets to go through.  This is also important to
   unfreezing candidates at the right time.  While not crucial,
   preserving this behavior in Trickle ICE is likely to improve ICE
   performance.

   To achieve this, when trickling candidates, agents SHOULD respect the
   order of components as reflected by their component IDs; that is,
   candidates for a given component SHOULD NOT be conveyed prior to



Ivov, et al.            Expires October 17, 2018               [Page 19]

Internet-Draft                 Trickle ICE                    April 2018


   candidates for a component with a lower ID number within the same
   foundation.  In addition, candidates SHOULD be paired, following the
   procedures in Section 12, in the same order they are conveyed.

   For example, the following SDP description contains two components
   (RTP and RTCP) and two foundations (host and server reflexive):


     v=0
     o=jdoe 2890844526 2890842807 IN IP4 10.0.1.1
     s=
     c=IN IP4 10.0.1.1
     t=0 0
     a=ice-pwd:asd88fgpdd777uzjYhagZg
     a=ice-ufrag:8hhY
     m=audio 5000 RTP/AVP 0
     a=rtpmap:0 PCMU/8000
     a=candidate:1 1 UDP 2130706431 10.0.1.1 5000 typ host
     a=candidate:1 2 UDP 2130706431 10.0.1.1 5001 typ host
     a=candidate:2 1 UDP 1694498815 192.0.2.3 5000 typ srflx
         raddr 10.0.1.1 rport 8998
     a=candidate:2 2 UDP 1694498815 192.0.2.3 5001 typ srflx
         raddr 10.0.1.1 rport 8998


   For this candidate information the RTCP host candidate would not be
   conveyed prior to the RTP host candidate.  Similarly the RTP server
   reflexive candidate would be conveyed together with or prior to the
   RTCP server reflexive candidate.

18.  Requirements for Using Protocols

   In order to fully enable the use of Trickle ICE, this specification
   defines the following requirements for using protocols.

   o  A using protocol SHOULD provide a way for parties to advertise and
      discover support for Trickle ICE before an ICE session begins (see
      Section 3).

   o  A using protocol MUST provide methods for incrementally conveying
      (i.e., "trickling") additional candidates after conveying the
      initial ICE description (see Section 9).

   o  A using protocol MUST deliver each trickled candidate or end-of-
      candidates indication exactly once and in the same order it was
      conveyed (see Section 9).





Ivov, et al.            Expires October 17, 2018               [Page 20]

Internet-Draft                 Trickle ICE                    April 2018


   o  A using protocol MUST provide a mechanism for both parties to
      indicate and agree on the ICE session in force (see Section 9).

   o  A using protocol MUST provide a way for parties to communicate the
      end-of-candidates indication, which MUST specify the particular
      ICE session to which the indication applies (see Section 13).

19.  IANA Considerations

   IANA is requested to register the following ICE option in the "ICE
   Options" sub-registry of the "Interactive Connectivity Establishment
   (ICE) registry", following the procedures defined in [RFC6336].

   ICE Option:  trickle

   Contact:  IESG, iesg@ietf.org

   Change control:  IESG

   Description:  An ICE option of "trickle" indicates support for
      incremental communication of ICE candidates.

   Reference:  RFC XXXX

20.  Security Considerations

   This specification inherits most of its semantics from [rfc5245bis]
   and as a result all security considerations described there apply to
   Trickle ICE.

   If the privacy implications of revealing host addresses on an
   endpoint device are a concern (see for example the discussion in
   [I-D.ietf-rtcweb-ip-handling] and in Section 19 of [rfc5245bis]),
   agents can generate ICE descriptions that contain no candidates and
   then only trickle candidates that do not reveal host addresses (e.g.,
   relayed candidates).

21.  Acknowledgements

   The authors would like to thank Bernard Aboba, Flemming Andreasen,
   Rajmohan Banavi, Taylor Brandstetter, Philipp Hancke, Christer
   Holmberg, Ari Keranen, Paul Kyzivat, Jonathan Lennox, Enrico Marocco,
   Pal Martinsen, Nils Ohlmeier, Thomas Stach, Peter Thatcher, Martin
   Thomson, Brandon Williams, and Dale Worley for their reviews and
   suggestions on improving this document.  Sarah Banks, Roni Even, and
   David Mandelberg completed opsdir, genart, and security reviews,
   respectively.  Thanks also to Ari Keranen and Peter Thatcher in their




Ivov, et al.            Expires October 17, 2018               [Page 21]

Internet-Draft                 Trickle ICE                    April 2018


   role as chairs, and Ben Campbell in his role as responsible Area
   Director.

22.  References

22.1.  Normative References

   [RFC2119]  Bradner, S., "Key words for use in RFCs to Indicate
              Requirement Levels", BCP 14, RFC 2119,
              DOI 10.17487/RFC2119, March 1997, <https://www.rfc-
              editor.org/info/rfc2119>.

   [rfc5245bis]
              Keranen, A., Holmberg, C., and J. Rosenberg, "Interactive
              Connectivity Establishment (ICE): A Protocol for Network
              Address Translator (NAT) Traversal", draft-ietf-ice-
              rfc5245bis-20 (work in progress), March 2018.

22.2.  Informative References

   [I-D.ietf-mmusic-trickle-ice-sip]
              Ivov, E., Stach, T., Marocco, E., and C. Holmberg, "A
              Session Initiation Protocol (SIP) usage for Trickle ICE",
              draft-ietf-mmusic-trickle-ice-sip-14 (work in progress),
              February 2018.

   [I-D.ietf-rtcweb-ip-handling]
              Uberti, J. and G. Shieh, "WebRTC IP Address Handling
              Requirements", draft-ietf-rtcweb-ip-handling-06 (work in
              progress), March 2018.

   [RFC1918]  Rekhter, Y., Moskowitz, B., Karrenberg, D., de Groot, G.,
              and E. Lear, "Address Allocation for Private Internets",
              BCP 5, RFC 1918, DOI 10.17487/RFC1918, February 1996,
              <https://www.rfc-editor.org/info/rfc1918>.

   [RFC3261]  Rosenberg, J., Schulzrinne, H., Camarillo, G., Johnston,
              A., Peterson, J., Sparks, R., Handley, M., and E.
              Schooler, "SIP: Session Initiation Protocol", RFC 3261,
              DOI 10.17487/RFC3261, June 2002, <https://www.rfc-
              editor.org/info/rfc3261>.

   [RFC3264]  Rosenberg, J. and H. Schulzrinne, "An Offer/Answer Model
              with Session Description Protocol (SDP)", RFC 3264,
              DOI 10.17487/RFC3264, June 2002, <https://www.rfc-
              editor.org/info/rfc3264>.





Ivov, et al.            Expires October 17, 2018               [Page 22]

Internet-Draft                 Trickle ICE                    April 2018


   [RFC4566]  Handley, M., Jacobson, V., and C. Perkins, "SDP: Session
              Description Protocol", RFC 4566, DOI 10.17487/RFC4566,
              July 2006, <https://www.rfc-editor.org/info/rfc4566>.

   [RFC4787]  Audet, F., Ed. and C. Jennings, "Network Address
              Translation (NAT) Behavioral Requirements for Unicast
              UDP", BCP 127, RFC 4787, DOI 10.17487/RFC4787, January
              2007, <https://www.rfc-editor.org/info/rfc4787>.

   [RFC5389]  Rosenberg, J., Mahy, R., Matthews, P., and D. Wing,
              "Session Traversal Utilities for NAT (STUN)", RFC 5389,
              DOI 10.17487/RFC5389, October 2008, <https://www.rfc-
              editor.org/info/rfc5389>.

   [RFC5766]  Mahy, R., Matthews, P., and J. Rosenberg, "Traversal Using
              Relays around NAT (TURN): Relay Extensions to Session
              Traversal Utilities for NAT (STUN)", RFC 5766,
              DOI 10.17487/RFC5766, April 2010, <https://www.rfc-
              editor.org/info/rfc5766>.

   [RFC6120]  Saint-Andre, P., "Extensible Messaging and Presence
              Protocol (XMPP): Core", RFC 6120, DOI 10.17487/RFC6120,
              March 2011, <https://www.rfc-editor.org/info/rfc6120>.

   [RFC6336]  Westerlund, M. and C. Perkins, "IANA Registry for
              Interactive Connectivity Establishment (ICE) Options",
              RFC 6336, DOI 10.17487/RFC6336, July 2011,
              <https://www.rfc-editor.org/info/rfc6336>.

   [XEP-0030]
              Hildebrand, J., Millard, P., Eatmon, R., and P. Saint-
              Andre, "XEP-0030: Service Discovery", XEP XEP-0030, June
              2008.

   [XEP-0176]
              Beda, J., Ludwig, S., Saint-Andre, P., Hildebrand, J.,
              Egan, S., and R. McQueen, "XEP-0176: Jingle ICE-UDP
              Transport Method", XEP XEP-0176, June 2009.

Appendix A.  Interaction with Regular ICE

   The ICE protocol was designed to be flexible enough to work in and
   adapt to as many network environments as possible.  Despite that
   flexibility, ICE as specified in [rfc5245bis] does not by itself
   support trickle ICE.  This section describes how trickling of
   candidates interacts with ICE.





Ivov, et al.            Expires October 17, 2018               [Page 23]

Internet-Draft                 Trickle ICE                    April 2018


   [rfc5245bis] describes the conditions required to update check lists
   and timer states while an ICE agent is in the Running state.  These
   conditions are verified upon transaction completion and one of them
   stipulates that:

      If there is not a pair in the valid list for each component of the
      data stream, the state of the check list is set to Failed.

   This could be a problem and cause ICE processing to fail prematurely
   in a number of scenarios.  Consider the following case:

   1.  Alice and Bob are both located in different networks with Network
       Address Translation (NAT).  Alice and Bob themselves have
       different address but both networks use the same private internet
       block (e.g., the "20-bit block" 172.16/12 specified in
       [RFC1918]).

   2.  Alice conveys to Bob the candidate 172.16.0.1 which also happens
       to correspond to an existing host on Bob's network.

   3.  Bob creates a check list consisting solely of 172.16.0.1 and
       starts checks.

   4.  These checks reach the host at 172.16.0.1 in Bob's network, which
       responds with an ICMP "port unreachable" error; per [rfc5245bis]
       Bob marks the transaction as Failed.

   At this point the check list only contains Failed candidates and the
   valid list is empty.  This causes the data stream and potentially all
   ICE processing to fail, even though if Trickle ICE agents could
   subsequently convey candidates that would cause previously empty
   check lists to become non-empty.

   A similar race condition would occur if the initial ICE description
   from Alice contain only candidates that can be determined as
   unreachable from any of the candidates that Bob has gathered (e.g.,
   this would be the case if Bob's candidates only contain IPv4
   addresses and the first candidate that he receives from Alice is an
   IPv6 one).

   Another potential problem could arise when a non-trickle ICE
   implementation initiates an interaction with a Trickle ICE
   implementation.  Consider the following case:

   1.  Alice's client has a non-Trickle ICE implementation.

   2.  Bob's client has support for Trickle ICE.




Ivov, et al.            Expires October 17, 2018               [Page 24]

Internet-Draft                 Trickle ICE                    April 2018


   3.  Alice and Bob are behind NATs with address-dependent filtering
       [RFC4787].

   4.  Bob has two STUN servers but one of them is currently
       unreachable.

   After Bob's agent receives Alice's initial ICE description it would
   immediately start connectivity checks.  It would also start gathering
   candidates, which would take a long time because of the unreachable
   STUN server.  By the time Bob's answer is ready and conveyed to
   Alice, Bob's connectivity checks might have failed: until Alice gets
   Bob's answer, she won't be able to start connectivity checks and
   punch holes in her NAT.  The NAT would hence be filtering Bob's
   checks as originating from an unknown endpoint.

Appendix B.  Interaction with ICE Lite

   The behavior of ICE lite agents that are capable of Trickle ICE does
   not require any particular rules other than those already defined in
   this specification and [rfc5245bis].  This section is hence provided
   only for informational purposes.

   An ICE lite agent would generate candidate information as per
   [rfc5245bis] and would indicate support for Trickle ICE.  Given that
   the candidate information will contain a full generation of
   candidates, it would also be accompanied by an end-of-candidates
   indication.

   When performing full trickle, a full ICE implementation could convey
   the initial ICE description or response thereto with no candidates.
   After receiving a response that identifies the remote agent as an ICE
   lite implementation, the initiator can choose to not trickle any
   additional candidates.  The same is also true in the case when the
   ICE lite agent initiates the interaction and the full ICE agent is
   the responder.  In these cases the connectivity checks would be
   enough for the ICE lite implementation to discover all potentially
   useful candidates as peer reflexive.  The following example
   illustrates one such ICE session using SDP syntax:













Ivov, et al.            Expires October 17, 2018               [Page 25]

Internet-Draft                 Trickle ICE                    April 2018


           ICE Lite                                          Bob
            Agent
              |   Offer (a=ice-lite a=ice-options:trickle)    |
              |---------------------------------------------->|
              |                                               |no cand
              |         Answer (a=ice-options:trickle)        |trickling
              |<----------------------------------------------|
              |              Connectivity Checks              |
              |<--------------------------------------------->|
     peer rflx|                                               |
    cand disco|                                               |
              |<========== CONNECTION ESTABLISHED ===========>|



                             Figure 8: Example

   In addition to reducing signaling traffic this approach also removes
   the need to discover STUN bindings or make TURN allocations, which
   can considerably lighten ICE processing.

Appendix C.  Changes from Earlier Versions

   Note to the RFC Editor: please remove this section prior to
   publication as an RFC.

C.1.  Changes from draft-ietf-ice-trickle-20

   o  Slight corrections to hanlding of peer reflexive candidates.

   o  Wordsmithing in a few sections.

C.2.  Changes from draft-ietf-ice-trickle-19

   o  Further clarified handling of remote peer reflexive candidates.

   o  To improve readibility, renamed and restructured some sections and
      subsections, and modified some wording.

C.3.  Changes from draft-ietf-ice-trickle-18

   o  Cleaned up pairing and redundancy checking rules for newly
      discovered candidates per IESG feedback and WG discussion.

   o  Improved wording in half trickle section.

   o  Changed "not more than once" to "exactly once".




Ivov, et al.            Expires October 17, 2018               [Page 26]

Internet-Draft                 Trickle ICE                    April 2018


   o  Changed NAT examples back to IPv4.

C.4.  Changes from draft-ietf-ice-trickle-17

   o  Simplified the rules for inserting a new pair in a check list.

   o  Clarified it is not allowed to nominate a candidate pair after a
      pair has already been nominated (a.k.a.  renomination or
      continuous nomination).

   o  Removed some text that referenced older versions of rfc5245bis.

   o  Removed some text that duplicated concepts and procedures
      specified in rfc5245bis.

   o  Removed the ill-defined concept of stream order.

   o  Shortened the introduction.

C.5.  Changes from draft-ietf-ice-trickle-16

   o  Made "ufrag" terminology consistent with 5245bis.

   o  Applied in-order delivery rule to end-of-candidates indication.

C.6.  Changes from draft-ietf-ice-trickle-15

   o  Adjustments to address AD review feedback.

C.7.  Changes from draft-ietf-ice-trickle-14

   o  Minor modifications to track changes to ICE core.

C.8.  Changes from draft-ietf-ice-trickle-13

   o  Removed independent monitoring of check list "states" of frozen or
      active, since this is handled by placing a check list in the
      Running state defined in ICE core.

C.9.  Changes from draft-ietf-ice-trickle-12

   o  Specified that the end-of-candidates indication must include the
      generation (ufrag/pwd) to enable association with a particular ICE
      session.

   o  Further editorial fixes to address WGLC feedback.





Ivov, et al.            Expires October 17, 2018               [Page 27]

Internet-Draft                 Trickle ICE                    April 2018


C.10.  Changes from draft-ietf-ice-trickle-11

   o  Editorial and terminological fixes to address WGLC feedback.

C.11.  Changes from draft-ietf-ice-trickle-10

   o  Minor editorial fixes.

C.12.  Changes from draft-ietf-ice-trickle-09

   o  Removed immediate unfreeze upon Fail.

   o  Specified MUST NOT regarding ice-options.

   o  Changed terminology regarding initial ICE parameters to avoid
      implementer confusion.

C.13.  Changes from draft-ietf-ice-trickle-08

   o  Reinstated text about in-order processing of messages as a
      requirement for signaling protocols.

   o  Added IANA registration template for ICE option.

   o  Corrected Case 3 rule in Section 8.1.1 to ensure consistency with
      regular ICE rules.

   o  Added tabular representations to Section 8.1.1 in order to
      illustrate the new pair rules.

C.14.  Changes from draft-ietf-ice-trickle-07

   o  Changed "ICE description" to "candidate information" for
      consistency with 5245bis.

C.15.  Changes from draft-ietf-ice-trickle-06

   o  Addressed editorial feedback from chairs' review.

   o  Clarified terminology regarding generations.

C.16.  Changes from draft-ietf-ice-trickle-05

   o  Rewrote the text on inserting a new pair into a check list.







Ivov, et al.            Expires October 17, 2018               [Page 28]

Internet-Draft                 Trickle ICE                    April 2018


C.17.  Changes from draft-ietf-ice-trickle-04

   o  Removed dependency on SDP and offer/answer model.

   o  Removed mentions of aggressive nomination, since it is deprecated
      in 5245bis.

   o  Added section on requirements for signaling protocols.

   o  Clarified terminology.

   o  Addressed various WG feedback.

C.18.  Changes from draft-ietf-ice-trickle-03

   o  Provided more detailed description of unfreezing behavior,
      specifically how to replace pre-existing peer-reflexive candidates
      with higher-priority ones received via trickling.

C.19.  Changes from draft-ietf-ice-trickle-02

   o  Adjusted unfreezing behavior when there are disparate foundations.

C.20.  Changes from draft-ietf-ice-trickle-01

   o  Changed examples to use IPv6.

C.21.  Changes from draft-ietf-ice-trickle-00

   o  Removed dependency on SDP (which is to be provided in a separate
      specification).

   o  Clarified text about the fact that a check list can be empty if no
      candidates have been sent or received yet.

   o  Clarified wording about check list states so as not to define new
      states for "Active" and "Frozen" because those states are not
      defined for check lists (only for candidate pairs) in ICE core.

   o  Removed open issues list because it was out of date.

   o  Completed a thorough copy edit.

C.22.  Changes from draft-mmusic-trickle-ice-02

   o  Addressed feedback from Rajmohan Banavi and Brandon Williams.





Ivov, et al.            Expires October 17, 2018               [Page 29]

Internet-Draft                 Trickle ICE                    April 2018


   o  Clarified text about determining support and about how to proceed
      if it can be determined that the answering agent does not support
      Trickle ICE.

   o  Clarified text about check list and timer updates.

   o  Clarified when it is appropriate to use half trickle or to send no
      candidates in an offer or answer.

   o  Updated the list of open issues.

C.23.  Changes from draft-ivov-01 and draft-mmusic-00

   o  Added a requirement to trickle candidates by order of components
      to avoid deadlocks in the unfreezing algorithm.

   o  Added an informative note on peer-reflexive candidates explaining
      that nothing changes for them semantically but they do become a
      more likely occurrence for Trickle ICE.

   o  Limit the number of pairs to 100 to comply with 5245.

   o  Added clarifications on the non-importance of how newly discovered
      candidates are trickled/sent to the remote party or if this is
      done at all.

   o  Added transport expectations for trickled candidates as per Dale
      Worley's recommendation.

C.24.  Changes from draft-ivov-00

   o  Specified that end-of-candidates is a media level attribute which
      can of course appear as session level, which is equivalent to
      having it appear in all m-lines.  Also made end-of-candidates
      optional for cases such as aggressive nomination for controlled
      agents.

   o  Added an example for ICE lite and Trickle ICE to illustrate how,
      when talking to an ICE lite agent doesn't need to send or even
      discover any candidates.

   o  Added an example for ICE lite and Trickle ICE to illustrate how,
      when talking to an ICE lite agent doesn't need to send or even
      discover any candidates.

   o  Added wording that explicitly states ICE lite agents have to be
      prepared to receive no candidates over signaling and that they




Ivov, et al.            Expires October 17, 2018               [Page 30]

Internet-Draft                 Trickle ICE                    April 2018


      should not freak out if this happens.  (Closed the corresponding
      open issue).

   o  It is now mandatory to use MID when trickling candidates and using
      m-line indexes is no longer allowed.

   o  Replaced use of 0.0.0.0 to IP6 :: in order to avoid potential
      issues with RFC2543 SDP libraries that interpret 0.0.0.0 as an on-
      hold operation.  Also changed the port number here from 1 to 9
      since it already has a more appropriate meaning.  (Port change
      suggested by Jonathan Lennox).

   o  Closed the Open Issue about use about what to do with cands
      received after end-of-cands.  Solution: ignore, do an ICE restart
      if you want to add something.

   o  Added more terminology, including trickling, trickled candidates,
      half trickle, full trickle,

   o  Added a reference to the SIP usage for Trickle ICE as requested at
      the Boston interim.

C.25.  Changes from draft-rescorla-01

   o  Brought back explicit use of Offer/Answer.  There are no more
      attempts to try to do this in an O/A independent way.  Also
      removed the use of ICE Descriptions.

   o  Added SDP specification for trickled candidates, the trickle
      option and 0.0.0.0 addresses in m-lines, and end-of-candidates.

   o  Support and Discovery.  Changed that section to be less abstract.
      As discussed in IETF85, the draft now says implementations and
      usages need to either determine support in advance and directly
      use trickle, or do half trickle.  Removed suggestion about use of
      discovery in SIP or about letting implementing protocols do what
      they want.

   o  Defined Half Trickle.  Added a section that says how it works.
      Mentioned that it only needs to happen in the first o/a (not
      necessary in updates), and added Jonathan's comment about how it
      could, in some cases, offer more than half the improvement if you
      can pre-gather part or all of your candidates before the user
      actually presses the call button.

   o  Added a short section about subsequent offer/answer exchanges.





Ivov, et al.            Expires October 17, 2018               [Page 31]

Internet-Draft                 Trickle ICE                    April 2018


   o  Added a short section about interactions with ICE Lite
      implementations.

   o  Added two new entries to the open issues section.

C.26.  Changes from draft-rescorla-00

   o  Relaxed requirements about verifying support following a
      discussion on MMUSIC.

   o  Introduced ICE descriptions in order to remove ambiguous use of
      3264 language and inappropriate references to offers and answers.

   o  Removed inappropriate assumption of adoption by RTCWEB pointed out
      by Martin Thomson.

Authors' Addresses

   Emil Ivov
   Atlassian
   303 Colorado Street, #1600
   Austin, TX  78701
   USA

   Phone: +1-512-640-3000
   Email: eivov@atlassian.com


   Eric Rescorla
   RTFM, Inc.
   2064 Edgewood Drive
   Palo Alto, CA  94303
   USA

   Phone: +1 650 678 2350
   Email: ekr@rtfm.com


   Justin Uberti
   Google
   747 6th St S
   Kirkland, WA  98033
   USA

   Phone: +1 857 288 8888
   Email: justin@uberti.name





Ivov, et al.            Expires October 17, 2018               [Page 32]

Internet-Draft                 Trickle ICE                    April 2018


   Peter Saint-Andre
   Mozilla
   P.O. Box 787
   Parker, CO  80134
   USA

   Phone: +1 720 256 6756
   Email: stpeter@mozilla.com
   URI:   https://www.mozilla.com/










































Ivov, et al.            Expires October 17, 2018               [Page 33]
