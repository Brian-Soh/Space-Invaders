;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname |New Space Invaders|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;;Coded by Brian Soh

(require spd/tags)
(require 2htdp/image)
(require 2htdp/universe)

;; Space Invaders

(@htdw Ship) ;(give WS a better name)

;; =================
;; Constants:

(define HEIGHT 750)
(define WIDTH 600)

(define TOP 100)
(define BOTTOM (- HEIGHT 1))
(define LEF 0)
(define RIG (- WIDTH 1))

(define PLAYER-Y (- BOTTOM 60))
(define PLAYER-SPEED 14.5)
(define ALIEN-SPEED-X 0.5)
(define ALIEN-SPEED-Y 10)
(define PLAYER-BULLET-SPEED -25)

(define PLAYER-BULLET (rectangle 5 20 "solid" "white"))
(define ALIEN-BULLET (rectangle 5 20 "solid" "green"))

(define TEXT-SIZE 24)
(define TEXT-COLOUR "white")
(define SC-HEIGHT 50)
(define HS-HEIGHT 50)
(define LVL-HEIGHT 50)

(define HIGH-SCORE-TEXT (text "HIGH-SCORE" TEXT-SIZE TEXT-COLOUR))
(define SCORE-TEXT (text "SCORE" TEXT-SIZE TEXT-COLOUR))
(define LEVEL-TEXT (text "LEVEL" TEXT-SIZE TEXT-COLOUR))
(define SCORE-SPACING (rectangle (/ (- (/ WIDTH 2) (image-width SCORE-TEXT)
                                       (/ (image-width HIGH-SCORE-TEXT) 2)) 2)
                                 0 "solid" "transparent"))

(define SHIP (bitmap/url "https://i.ibb.co/KyJCzx7/Spaceship.png"))
(define ALIEN (bitmap/url "https://i.ibb.co/FBxGBy1/Alien1.png"))
(define DEAD-ALIEN (rectangle (image-width ALIEN) (image-height ALIEN) "solid" "transparent"))

(define MTS
  (overlay/align "middle" "top" HIGH-SCORE-TEXT
                 (overlay/align "right" "top"
                                (beside LEVEL-TEXT SCORE-SPACING)
                                (overlay/align "left" "top"
                                               (beside SCORE-SPACING SCORE-TEXT)
                                               (rectangle WIDTH HEIGHT "solid"
                                                          "black")))))
         
;; =================
;; Data definitions:

(@htdd Ship)
(define-struct ship (x y))
;; Ship is (make-ship Integer Integer)
;; interp. (make-ship x y) is the player's ship at position x y
(define S0 (make-ship 0 PLAYER-Y))
(define S1 (make-ship (/ WIDTH 2) PLAYER-Y))

(@dd-template-rules compound) ;2 fields

(define (fn-for-ship s)
  (... (ship-x s)
       (ship-y s)))

;; ALIEN DATA

(@htdd Alien)
(define-struct alien (x y dx dy))
;; Alien is (make-alien Integer  Integer Integer Integer)
;; interp. (make-alien x y dy) is Alien with position x y and speed dx and dy
(define A1 (make-alien 0 (/ HEIGHT 2) ALIEN-SPEED-X ALIEN-SPEED-Y))
(define A2 (make-alien 50 (- (/ HEIGHT 2) 250) ALIEN-SPEED-X ALIEN-SPEED-Y))

(@htdd DeadAlien)
(define-struct dead-alien (x y dx dy))
;; DeadAlien is (make-dead-alien Integer Integer Integer Integer)
;; interp. (make-dead-alien x y dy) is Dead Alien with position x y and speed dx and dy

(@htdd ListOfAlien)
;; ListOfAlien is one of:
;; - empty
;; - (cons Alien ListOfAlien)
;; - (cons DeadAlien ListOfAlien)


(define LOA-1
  (local [(define (make-row x rnr)
            (local [(define (make-a n)
                      (make-alien (- (* 50 n) 15) (- (/ HEIGHT 2) 100 (* 50 x)) ALIEN-SPEED-X ALIEN-SPEED-Y))]
              (append (map make-a (build-list 10 add1)) rnr)))]
    (foldr make-row empty (build-list 4 identity))))

(define LOA-2 (list A1 A2))

(define ROWS
  (list (list 0 1 2 3 4 5 6 7 8 9)
        (list 10 11 12 13 14 15 16 17 18 19)
        (list 20 21 22 23 24 25 26 27 28 29)
        (list 30 31 32 33 34 35 36 37 38 39)))

(define COLS
  (list (list 0 10 20 30)
        (list 1 11 21 31)
        (list 2 12 22 32)
        (list 3 13 23 33)
        (list 4 14 24 34)
        (list 5 15 25 35)
        (list 6 16 26 36)
        (list 7 17 27 37)
        (list 8 18 28 38)
        (list 9 19 29 39)))
                        
             
             
;; SCORE DATA

(@htdd Score)
;; Score is Number [0, 9999]
;; interp. the player score, starts at zero
(define SC0 0)
(define SC100 100)
(define SC9999 9999)

(define (fn-for-score sc)
  (... sc))

(@htdd HighScore)
;; High-Score is Number [0, 9999]
;; interp. the highest score, starts at zero, updates when a new high score is
;;         reached
(define HS0 0)
(define HS100 100)
(define HS9999 9999)

(define (fn-for-high-score hs)
  (... hs))

(@htdd Level)
;; Level is Number [0, 9999]
;; interp. the game level, starts at zero
(define LVL1 1)
(define LVL100 100)
(define LVL9999 9999)

(define (fn-for-level lvl)
  (... lvl))

;; BULLET DATA

(@htdd PlayerBullet)
(define-struct p-bullet (x y dy))
;; Bullet is (make-p-bullet Integer Integer Integer)
;; interp. (make-p-bullet x y dy) is a bullet with position x y and speed dy

(define (fn-for-pb pb)
  (... (p-bullet-x pb)
       (p-bullet-y pb)
       (p-pullet-dy pb)))

(define PB0 (make-p-bullet 0 0 PLAYER-BULLET-SPEED))
(define PB1 (make-p-bullet (/ WIDTH 2) (/ HEIGHT 2) PLAYER-BULLET-SPEED))

(@htdd ListOfPlayerBullet)
;; ListOfPlayerBullet is one of:
;; - empty
;; (cons PlayerBullet ListOfPlayerBullet)

(define LOPB-0 empty)
(define LOPB-1 (list PB0 PB1))

(@dd-template-rules one-of
                    atomic-distinct
                    compound
                    ref
                    self-ref)

(define (fn-for-lopb lopb)
  (cond [(empty? lopb) (...)]
        [else
         (... (fn-for-pb (first lopb))
              (fn-for-lopb (rest lopb)))]))

(@htdd AlienBullet)
(define-struct a-bullet (x y dy))
;; Bullet is (make-a-bullet Integer Integer Integer)
;; interp. (make-a-bullet x y dy) is a bullet with position x y and speed dy

(define (fn-for-ab ab)
  (... (a-bullet-x ab)
       (a-bullet-y ab)
       (a-bullet-dy ab)))

(define AB0 (make-a-bullet 0 0 5))
(define AB1 (make-a-bullet (/ WIDTH 2) (/ HEIGHT 2) 10))

(@htdd ListOfAlienBullet)
;; ListOfAlienBullet is one of:
;; - empty
;; (cons AlienBullet ListOfAlienBullet)

(define LOAB-0 empty)
(define LOAB-1 (list AB0 AB1))

(@dd-template-rules one-of
                    atomic-distinct
                    compound
                    ref
                    self-ref)

(define (fn-for-loab loab)
  (cond [(empty? loab) (...)]
        [else
         (... (fn-for-ab (first loab))
              (fn-for-loab (rest loab)))]))

(@htdd Game)
(define-struct game (s loa lopb loab sc hs lvl))
;; Game is (make-game Ship ListOfAliens ListOfPlayerBullet ListOfAlienBullet
;;          Score HighScore Level)
;; interp. (make-game s loa lopb loab sc hs lvl) is a game with ship s, aliens loa,
;;         player bullets lopb, alien bullets loab, score sc, highscore hs, and level lvl
(define G0 (make-game S1 LOA-1 LOPB-0 LOAB-0 SC0 HS0 LVL1))

(define (fn-for-game g)
  (... (game-s g)
       (game-loa g)
       (game-lopb g)
       (game-loab g)
       (game-sc g)
       (game-hs g)
       (game-lvl g)))

;; =================
;; Functions:

(@htdf main)
(@signature Game -> Game)
;; start the world with (main G0)

(@template-origin htdw-main)

(define (main g)
  (big-bang g                   ; Game
    (on-tick   next-game)     ; Game -> Game
    (to-draw   render-game)   ; Game -> Image
    (on-mouse  fire)      ; Game  Integer Integer MouseEvent -> WS
    (on-key    move)))   ; Game KeyEvent -> Ship

(define (next-game g)
  (local [(define (all-dead? loa) (empty? (filter alien? loa)))]
    (shoot-alien-bullets (filter-hits (filter-bullets
                  (make-game (game-s g)
                             (next-loa (first (game-loa g))
                                       (if (all-dead? (game-loa g))
                                           LOA-1
                                           (game-loa g)))
                             (next-lopb (game-lopb g))
                             (next-loab (game-loab g))
                             (game-sc g)
                             (game-hs g)
                             (if (all-dead? (game-loa g))
                                 (add1(game-lvl g))
                                 (game-lvl g))))))))

(@htdf filter-bullets)
(@signature Game -> Game)
;; filters the game for colliding bullets
 
(@template-origin Game)

(define (filter-bullets g)
  (make-game (game-s g)
             (game-loa g)
             (filter (lambda (pb) (not (collide-pbloab? pb (game-loab g)))) (game-lopb g))
             (filter (lambda (ab) (not (collide-ablopb? ab (game-lopb g)))) (game-loab g))
             (game-sc g)
             (game-hs g)
             (game-lvl g)))


(@htdf filter-hits)
(@signature Game -> Game)
;; filters the game for colliding bullets with player or aliens

(@template-origin Game)

(define (filter-hits g)
  (if (collision-sloab? (game-s g) (game-loab g))
      (make-game S1 LOA-1 LOPB-0 LOAB-0 SC0 (max HS0 (game-sc g)) LVL1)
      (local [(define (filter-alien a)(if (alien? a)
                                          (if (collision-alopb? a (game-lopb g))
                                              (make-da a)
                                              a)
                                          a))
              (define (count-hits a rnr)
                (cond [(dead-alien? a) rnr]
                      [(collision-alopb? a (game-lopb g)) (+ 100 rnr)]
                      [else
                       rnr]))
              (define (make-da a) (make-dead-alien (alien-x a) (alien-y a) (alien-dx a) (alien-dy a)))]
        (make-game (game-s g)
                   (map filter-alien (game-loa g))
                   (filter (lambda (pb) (not (collide-pbloa? pb (game-loa g)))) (game-lopb g))
                   (game-loab g) 
                   (+ (game-sc g) (foldr count-hits 0 (game-loa g)))
                   (game-hs g)
                   (game-lvl g)))))

(@htdf shoot-alien-bullets)
(@signature Game -> Game)
;; shoots alien bullets
(@template-origin Game)

(define (shoot-alien-bullets g)
  (make-game (game-s g)
       (game-loa g)
       (game-lopb g)
       (new-alien-bullets (game-loab g) (game-loa g) (game-lvl g) COLS)
       (game-sc g)
       (game-hs g)
       (game-lvl g)))

(@htdf new-alien-bullets)
(@signature (listof AlienBullet) (listof Alien) Level (listof (listof Natural)) -> (listof AlienBullet))
;; produces new alien bullets

(@template-origin 2-one-of)

(define (new-alien-bullets loab loa lvl cols)
  (local [(define (new-alien-bullet lop loa)
            (cond [(empty? lop) false]
                  [(dead-alien? (list-ref loa (first lop))) (new-alien-bullet (rest lop) loa)]
                  [(and (alien? (list-ref loa (first lop))) (= (random 200) 1))
                   (make-a-bullet (alien-x (list-ref loa (first lop))) (+ (alien-y (list-ref loa (first lop))) (image-width ALIEN)) (* lvl 5))]
                  [else
                   false]))]
  (cond [(empty? cols) loab]
        [else
         (local [(define try (new-alien-bullet (first cols) loa))]
           (if (not (false? try))
               (cons try (new-alien-bullets loab loa lvl (rest cols)))
               (new-alien-bullets loab loa lvl (rest cols))))])))

        
(@htdf fire-bullet?)
(@signature (listof Alien) -> Boolean)
;; produces true if alien will shoot a bullet

(define (fire-bullet? loa) false)

(@htdf collide-pbloa?)
(@signature PlayerBullet (listof Alien) -> Boolean)
;; produces true if the player bullet has collided with an alien
(@template-origin (listof Alien))

(define (collide-pbloa? pb loa)
  (cond [(empty? loa) false]
        [(dead-alien? (first loa)) (collide-pbloa? pb (rest loa))]
        [else
         (or (and (< (- (alien-x (first loa)) (+ (/ (image-width ALIEN) 2) 3)) (p-bullet-x pb) (+ (alien-x (first loa)) (/ (image-height ALIEN) 2)))
                  (< (- (alien-y (first loa)) (+ (/ (image-width ALIEN) 2) 3)) (p-bullet-y pb) (+ (alien-y (first loa)) (/ (image-height ALIEN) 2))))
             (collide-pbloa? pb (rest loa)))]))


(@htdf collision-alopb?)
(@signature Alien (listof PlayerBullet) -> Boolean)
;; produces true if the Alien is hit by a player bullet
(@template-origin (listof PlayerBullet))

(define (collision-alopb? a lopb)
  (cond [(empty? lopb) false]
        [else
         (or (and (< (- (alien-x a) (+ (/ (image-width ALIEN) 2) 3)) (p-bullet-x (first lopb)) (+ (alien-x a) (/ (image-height ALIEN) 2)))
                  (< (- (alien-y a) (+ (/ (image-width ALIEN) 2) 3)) (p-bullet-y (first lopb)) (+ (alien-y a) (/ (image-height ALIEN) 2))))
             (collision-alopb? a (rest lopb)))]))

(@htdf collide-pbloab?)
(@signature PlayerBullet (listof AlienBullet) -> Boolean)
;; produces true if the player bullet has collided with an alien bullet
(@template-origin (listof AlienBullet))

(define (collide-pbloab? pb loab)
  (cond [(empty? loab) false]
        [else
         (or (and (< (- (a-bullet-x (first loab)) (image-width ALIEN-BULLET)) (p-bullet-x pb) (+ (a-bullet-x (first loab)) (image-width ALIEN-BULLET)))
                  (< (- (a-bullet-y (first loab)) (image-height ALIEN-BULLET)) (p-bullet-y pb) (+ (a-bullet-y (first loab)) (image-height ALIEN-BULLET))))
             (and (< (- (p-bullet-x pb) (image-width PLAYER-BULLET)) (a-bullet-x (first loab)) (+ (p-bullet-x pb) (image-width PLAYER-BULLET)))
                  (< (- (p-bullet-y pb) (image-height PLAYER-BULLET)) (a-bullet-y (first loab)) (+ (p-bullet-y pb) (image-height PLAYER-BULLET))))
             (collide-pbloab? pb (rest loab)))]))

(@htdf collide-ablopb?)
(@signature AlienBullet (listof PlayerBullet) -> Boolean)
;; produces true if the alien bullet has collided with a player bullet
(@template-origin (listof PlayerBullet))

(define (collide-ablopb? ab lopb)
  (cond [(empty? lopb) false]
        [else
         (or (and (< (- (p-bullet-x (first lopb)) (image-width PLAYER-BULLET)) (a-bullet-x ab) (+ (p-bullet-x (first lopb)) (image-width PLAYER-BULLET)))
                  (< (- (p-bullet-y (first lopb)) (image-height PLAYER-BULLET)) (a-bullet-y ab) (+ (p-bullet-y (first lopb)) (image-height PLAYER-BULLET))))
             (and (< (- (a-bullet-x ab) (image-width ALIEN-BULLET)) (p-bullet-x (first lopb)) (+ (a-bullet-x ab) (image-width ALIEN-BULLET)))
                  (< (- (a-bullet-y ab) (image-height ALIEN-BULLET)) (p-bullet-y (first lopb)) (+ (a-bullet-y ab) (image-height ALIEN-BULLET))))
             (collide-ablopb? ab (rest lopb)))]))


(@htdf collision-sloab?)
(@signature Ship (listof AlienBullet) -> Boolean)
;; produces true if list of alien bullet and ship have collided

(@template-origin (listof AlienBullet))

(define (collision-sloab? s loab)
  (cond [(empty? loab) false]
        [else
         (or (collision-sab? s (first loab)) (collision-sloab? s (rest loab)))]))


(@htdf collision-sab?)
(@signature Ship AlienBullet -> Boolean)
;; produces true if alien bullet and ship have collided

(@template-origin Ship)

(define (collision-sab? s ab)
  (and (< (- (ship-x s) (/ (image-width SHIP) 2)) (a-bullet-x ab) (+ (ship-x s) (/ (image-height SHIP) 2)))
       (< (- (ship-y s) (/ (image-width SHIP) 2)) (a-bullet-y ab) (+ (ship-y s) (/ (image-height SHIP) 2)))))
  

(@htdf next-loa)
;(@signature (Alien or DeadAlien) (listof Alien) -> (listof Alien))
;; produces the next list of aliens
(@template-origin (listof Alien))

(define (next-loa a loa)
  (local [(define (next-alien-x a)
            (make-alien (+ (alien-x a) (alien-dx a)) (alien-y a) (alien-dx a) (alien-dy a)))
          (define (next-alien-y a)
            (if (> (alien-dx a) 0)
                (make-alien (- (alien-x a) 1) (+ (alien-y a) (alien-dy a)) (- (alien-dx a)) (alien-dy a))
                (make-alien (+ (alien-x a) 1) (+ (alien-y a) (alien-dy a)) (- (alien-dx a)) (alien-dy a))))
          (define (next-alien-change-xy a) 
            (cond [(and (> (alien-dx a) 0) (> (alien-dy a) 0)) (make-alien (- (alien-x a) 1) (- (alien-y a) (alien-dy a) 1) (- (alien-dx a)) (- (alien-dy a)))]
                  [(and (> (alien-dx a) 0) (< (alien-dy a) 0)) (make-alien (- (alien-x a) 1) (- (alien-y a) (alien-dy a) (- 1)) (- (alien-dx a)) (- (alien-dy a)))]
                  [(and (< (alien-dx a) 0) (> (alien-dy a) 0)) (make-alien (+ (alien-x a) 1) (- (alien-y a) (alien-dy a) 1) (- (alien-dx a)) (- (alien-dy a)))]
                  [(and (< (alien-dx a) 0) (< (alien-dy a) 0)) (make-alien (+ (alien-x a) 1) (- (alien-y a) (alien-dy a) (- 1)) (- (alien-dx a)) (- (alien-dy a)))]))
          (define (next-dead-alien-x da)
            (make-dead-alien (+ (dead-alien-x da) (dead-alien-dx da)) (dead-alien-y da) (dead-alien-dx da) (dead-alien-dy da)))
          (define (next-dead-alien-y da) 
            (if (> (dead-alien-dx da) 0)
                (make-dead-alien (- (dead-alien-x da) 1) (+ (dead-alien-y da) (dead-alien-dy da)) (- (dead-alien-dx da)) (dead-alien-dy da))
                (make-dead-alien (+ (dead-alien-x da) 1) (+ (dead-alien-y da) (dead-alien-dy da)) (- (dead-alien-dx da)) (dead-alien-dy da))))
          (define (next-dead-alien-change-xy a)
            (make-dead-alien (dead-alien-x a) (+ (dead-alien-y a) (dead-alien-dy a)) (- (dead-alien-dx a)) (- (dead-alien-dy a))))]
    (cond [(empty? loa) empty]
          [(and (alien? a) (alien? (first loa)) (or (= 34 (alien-x a)) (= (alien-x a) 115)) (or (< 475 (alien-y a)) (> 275 (alien-y a))))
           (cons (next-alien-change-xy (first loa)) (next-loa a (rest loa)))]
          [(and (alien? a) (alien? (first loa)) (or (= 34 (alien-x a)) (= (alien-x a) 115)) (not (or (< 475 (alien-y a)) (> 275 (alien-y a)))))
           (cons (next-alien-y (first loa)) (next-loa a (rest loa)))]
          [(and (alien? a) (alien? (first loa)) (not (or (= 34 (alien-x a)) (= (alien-x a) 115))) (not (or (< 475 (alien-y a)) (> 275 (alien-y a)))))
           (cons (next-alien-x (first loa)) (next-loa a (rest loa)))]
          [(and (alien? a) (dead-alien? (first loa)) (or (= 34 (alien-x a)) (= (alien-x a) 115)) (or (< 475 (alien-y a)) (> 275 (alien-y a))))
           (cons (next-dead-alien-change-xy (first loa)) (next-loa a (rest loa)))]
          [(and (alien? a) (dead-alien? (first loa)) (or (= 34 (alien-x a)) (= (alien-x a) 115)) (not (or (< 475 (alien-y a)) (> 275 (alien-y a)))))
           (cons (next-dead-alien-y (first loa)) (next-loa a (rest loa)))]
          [(and (alien? a) (dead-alien? (first loa)) (not (or (= 34 (alien-x a)) (= (alien-x a) 115))) (not (or (< 475 (alien-y a)) (> 275 (alien-y a)))))
           (cons (next-dead-alien-x (first loa)) (next-loa a (rest loa)))]
          
          [(and (alien? (first loa)) (or (= 34 (dead-alien-x a)) (= (dead-alien-x a) 115)) (or (< 475 (dead-alien-y a)) (> 275 (dead-alien-y a))))
           (cons (next-alien-change-xy (first loa)) (next-loa a (rest loa)))]
          [(and (alien? (first loa)) (or (= 34 (dead-alien-x a)) (= (dead-alien-x a) 115)) (not (or (< 475 (dead-alien-y a)) (> 275 (dead-alien-y a)))))
           (cons (next-alien-y (first loa)) (next-loa a (rest loa)))]
          [(and  (alien? (first loa)) (not (or (= 34 (dead-alien-x a)) (= (dead-alien-x a) 115))) (not (or (< 475 (dead-alien-y a)) (> 275 (dead-alien-y a)))))
           (cons (next-alien-x (first loa)) (next-loa a (rest loa)))]
          [(and  (dead-alien? (first loa)) (or (= 34 (dead-alien-x a)) (= (dead-alien-x a) 115)) (or (< 475 (dead-alien-y a)) (> 275 (dead-alien-y a))))
           (cons (next-dead-alien-change-xy (first loa)) (next-loa a (rest loa)))]
          [(and  (dead-alien? (first loa)) (or (= 34 (dead-alien-x a)) (= (dead-alien-x a) 115)) (not (or (< 475 (dead-alien-y a)) (> 275 (dead-alien-y a)))))
           (cons (next-dead-alien-y (first loa)) (next-loa a (rest loa)))]
          [(and  (dead-alien? (first loa)) (not (or (= 34 (dead-alien-x a)) (= (dead-alien-x a) 115))) (not (or (< 475 (dead-alien-y a)) (> 275 (dead-alien-y a)))))
           (cons (next-dead-alien-x (first loa)) (next-loa a (rest loa)))])))

          

(@htdf next-lopb)
(@signature ListOfPlayerBullet -> ListOfPlayerBullet)
;; produces the next list of player bullets
(@template-origin ListOfPlayerBullet)

(define (next-lopb lopb)
  (local [(define (touch-top? b)
            (<= (+ (p-bullet-y b) (p-bullet-dy b)) TOP))]
    (cond [(empty? lopb) empty]
          [(touch-top? (first lopb)) (next-lopb (rest lopb))]
          [else
           (cons (next-pb (first lopb)) (next-lopb (rest lopb)))])))

(@htdf next-pb)
(@signature PlayerBullet -> PlayerBullet)
;; produces the next player bullet
(@template-origin PlayerBullet)

(define (next-pb pb)
  (make-p-bullet (p-bullet-x pb) (+ (p-bullet-y pb) (p-bullet-dy pb))
                 (p-bullet-dy pb)))

(@htdf next-loab)
(@signature ListOfAlienBullet -> ListOfAlienBullet)
;; produces the next list of alien bullets
(@template-origin ListOfAlienBullet)

(define (next-loab loab)
  (local [(define (touch-bottom? b)
            (>= (+ (a-bullet-y b) (a-bullet-dy b)) BOTTOM))]
    (cond [(empty? loab) empty]
          [(touch-bottom? (first loab)) (next-loab (rest loab))]
          [else
           (cons (next-ab (first loab)) (next-loab (rest loab)))])))

(@htdf next-ab)
(@signature AlienBullet -> AlienBullet)
;; produces the next alien bullet
(@template-origin AlienBullet)

(define (next-ab ab)
  (make-a-bullet (a-bullet-x ab) (+ (a-bullet-y ab) (a-bullet-dy ab))
                 (a-bullet-dy ab)))

(@htdf render-game)
(@signature Game -> Game)
;; renders the next tick of Game
(@template-origin Game)

(define (render-game g)
  (place-image SHIP (ship-x (game-s g)) (ship-y (game-s g))
               (place-image (text (number->string (game-sc g))
                                  TEXT-SIZE TEXT-COLOUR)
                            (+ (image-width SCORE-SPACING)
                               (/ (image-width SCORE-TEXT) 2))
                            SC-HEIGHT
                            (place-image (text (number->string (game-hs g))
                                               TEXT-SIZE TEXT-COLOUR)
                                         (/ WIDTH 2) HS-HEIGHT
                                         (place-image (text (number->string (game-lvl g))
                                                            TEXT-SIZE TEXT-COLOUR)
                                                      (- WIDTH (image-width SCORE-SPACING) (/ (image-width LEVEL-TEXT) 2)) LVL-HEIGHT
                                                      (render-loa-on (game-loa g)
                                                                     (render-lopb-on
                                                                      (game-lopb g)
                                                                      (render-loab-on
                                                                       (game-loab g)
                                                                       MTS))))))))

;; RENDER ALIEN FUNCTIONS

(@htdf render-alien-on)
; (@signature (Alien or DeadAlien) Image -> Image)
;; renders the alien onto given image
(@template-origin Alien)

(define (render-alien-on a img)
  (if (alien? a)
      (place-image ALIEN (alien-x a) (alien-y a) img)
      (place-image DEAD-ALIEN (dead-alien-x a) (dead-alien-y a) img)))

(@htdf render-loa-on)
(@signature ListOfAlien Image -> Image)
;; renders list of alien onto given image
(@template-origin ListOfAlien)

(define (render-loa-on loa img)
  (cond [(empty? loa) img]
        [else
         (render-alien-on (first loa) (render-loa-on (rest loa) img))]))

;; RENDER BULLETS
(@htdf render-player-bullet-on)
(@signature PlayerBullet Image -> Image)
;; renders player bullet onto given image
(@template-origin PlayerBullet)

(define (render-player-bullet-on pb img)
  (place-image PLAYER-BULLET (p-bullet-x pb) (p-bullet-y pb) img))

(@htdf render-lopb-on)
(@signature ListOfPlayerBullet Image -> Image)
;; renders list of player bullet onto given image
(@template-origin ListOfPlayerBullet)

(define (render-lopb-on lopb img)
  (cond [(empty? lopb) img]
        [else
         (render-player-bullet-on (first lopb) (render-lopb-on (rest lopb) img))]))

(@htdf render-alien-bullet-on)
(@signature AlienBullet Image -> Image)
;; renders alien bullet onto given image
(@template-origin AlienBullet)

(define (render-alien-bullet-on ab img)
  (place-image ALIEN-BULLET (a-bullet-x ab) (a-bullet-y ab) img))

(@htdf render-loab-on)
(@signature ListOfAlienBullet Image -> Image)
;; renders list of alien bullet onto given image
(@template-origin ListOfAlienBullet)

(define (render-loab-on loab img)
  (cond [(empty? loab) img]
        [else
         (render-alien-bullet-on (first loab)
                                 (render-loab-on (rest loab) img))]))

(@htdf fire)
(@signature Game Integer Integer MouseEvent -> Game)
;; Fires a bullet when mouse is clicked
(@template-origin MouseEvent)

(define (fire g x y me)
  (cond [(mouse=? me "button-down")
         (make-game (game-s g) (game-loa g)
                    (cons (make-p-bullet
                           (ship-x (game-s g))
                           (- (ship-y (game-s g)) (/ (image-height SHIP) 2))
                           PLAYER-BULLET-SPEED) (game-lopb g))
                    (game-loab g)
                    (game-sc g)
                    (game-hs g)
                    (game-lvl g))]
        [else g]))

(@htdf move)
(@signature Game KeyEvent -> Game)
;; moves the ship left and right when a and d are pressed respectfully
 
(define (move g ke)
  (local [(define (touch-left? s)
            (<= (- (- (ship-x (game-s g)) (/ (image-width SHIP) 2)) PLAYER-SPEED) LEF))
          (define (touch-right? s)
            (>= (+ (+ (ship-x (game-s g)) (/ (image-width SHIP) 2)) PLAYER-SPEED) RIG))]
    (cond [(and (not (touch-left? (game-s g))) (key=? ke "a"))
           (make-game (make-ship (- (ship-x (game-s g)) PLAYER-SPEED) PLAYER-Y)
                      (game-loa g)
                      (game-lopb g)
                      (game-loab g)
                      (game-sc g)
                      (game-hs g)
                      (game-lvl g))]
          [(and (not (touch-right? (game-s g))) (key=? ke "d"))
           (make-game (make-ship (+ (ship-x (game-s g)) PLAYER-SPEED) PLAYER-Y)
                      (game-loa g)
                      (game-lopb g)
                      (game-loab g)
                      (game-sc g)
                      (game-hs g)
                      (game-lvl g))]
          [else 
           g])))


