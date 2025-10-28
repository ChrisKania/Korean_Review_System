/**
 * Korean Learning API Client
 * Fixed version with proper Device ID handling
 */
class KoreanLearningAPI {
    constructor(baseUrl) {
        this.baseUrl = baseUrl || '/korean/api';
        this.deviceId = this.getOrCreateDeviceId();
        console.log('📱 Korean Learning API initialized');
        console.log('🔑 Device ID:', this.deviceId);
        console.log('🌐 Base URL:', this.baseUrl);
    }

    /**
     * Get or create a unique device identifier
     */
    getOrCreateDeviceId() {
        const storageKey = 'korean_device_id';
        let deviceId = localStorage.getItem(storageKey);
        
        if (!deviceId) {
            // Generate UUID v4-style device ID
            deviceId = 'device_' + this.generateUUID();
            localStorage.setItem(storageKey, deviceId);
            console.log('✨ New device ID generated:', deviceId);
        } else {
            console.log('♻️ Existing device ID loaded:', deviceId);
        }
        
        return deviceId;
    }

    /**
     * Generate a UUID
     */
    generateUUID() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            const r = Math.random() * 16 | 0;
            const v = c === 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }

    /**
     * Make an API request with proper device ID handling
     * FIXED: Now sends device ID in multiple ways to ensure it works
     */
    async request(endpoint, options = {}) {
        const url = `${this.baseUrl}/${endpoint}`;
        
        // Prepare headers
        const headers = {
            'Content-Type': 'application/json',
            'X-Device-ID': this.deviceId,  // Send as header
            ...options.headers
        };

        // Prepare request options
        const requestOptions = {
            ...options,
            headers: headers
        };

        // CRITICAL FIX: If it's a POST/PUT request, include device_id in body too
        if (options.method === 'POST' || options.method === 'PUT') {
            if (options.body) {
                try {
                    const bodyData = JSON.parse(options.body);
                    bodyData.device_id = this.deviceId;  // Add device ID to body
                    requestOptions.body = JSON.stringify(bodyData);
                } catch (e) {
                    // If body is not JSON, create new object
                    requestOptions.body = JSON.stringify({
                        ...options.bodyData,
                        device_id: this.deviceId
                    });
                }
            } else {
                requestOptions.body = JSON.stringify({ device_id: this.deviceId });
            }
        }

        // ALSO add as URL parameter for extra safety
        const urlWithDevice = url + (url.includes('?') ? '&' : '?') + `device_id=${this.deviceId}`;

        console.log('📤 API Request:', {
            url: urlWithDevice,
            method: options.method || 'GET',
            deviceId: this.deviceId
        });

        try {
            const response = await fetch(urlWithDevice, requestOptions);
            const data = await this.handleResponse(response);
            return data;
        } catch (error) {
            console.error('❌ API request failed:', error);
            throw error;
        }
    }

    /**
     * Handle API response
     */
    async handleResponse(response) {
        const text = await response.text();
        
        try {
            const data = JSON.parse(text);
            
            if (!response.ok) {
                throw new Error(data.message || `HTTP ${response.status}`);
            }
            
            return data;
        } catch (error) {
            if (error instanceof SyntaxError) {
                console.error('Invalid JSON response:', text);
                throw new Error('Invalid response from server');
            }
            throw error;
        }
    }

    /**
     * Get all lessons
     */
    async getLessons() {
        return await this.request('lessons.php?action=list');
    }

    /**
     * Get lesson details with vocabulary
     */
    async getLessonDetail(lessonId) {
        return await this.request(`lessons.php?action=detail&lesson_id=${lessonId}`);
    }

    /**
     * Get all vocabulary
     */
    async getAllVocabulary() {
        return await this.request('lessons.php?action=vocabulary');
    }

    /**
     * Get vocabulary by lesson
     */
    async getVocabularyByLesson(lessonId) {
        return await this.request(`lessons.php?action=vocabulary_by_lesson&lesson_id=${lessonId}`);
    }

    /**
     * Get user progress
     */
    async getProgress() {
        return await this.request('progress.php');
    }

    /**
     * Get user statistics
     */
    async getStats() {
        return await this.request('progress.php?action=stats');
    }

    /**
     * Get cards due for review today
     */
    async getDueCards() {
        return await this.request('progress.php?action=due_cards');
    }

    /**
     * Update progress for a single word
     * FIXED: Properly sends device ID in body
     */
    async updateProgress(wordId, isCorrect) {
        console.log('💾 Updating progress:', { wordId, isCorrect, deviceId: this.deviceId });
        
        return await this.request('progress.php', {
            method: 'POST',
            body: JSON.stringify({
                word_id: wordId,
                is_correct: isCorrect,
                device_id: this.deviceId  // Explicitly include in body
            })
        });
    }

    /**
     * Batch update progress (for import)
     */
    async batchUpdateProgress(progressData) {
        return await this.request('progress.php', {
            method: 'PUT',
            body: JSON.stringify({
                progress: progressData,
                device_id: this.deviceId  // Explicitly include in body
            })
        });
    }

    /**
     * Export progress
     */
    async exportProgress() {
        const progress = await this.getProgress();
        const stats = await this.getStats();
        
        return {
            device_id: this.deviceId,
            exported_at: new Date().toISOString(),
            progress: progress.data || {},
            stats: stats.data || {}
        };
    }

    /**
     * Import progress
     */
    async importProgress(importData) {
        if (!importData.progress) {
            throw new Error('Invalid import data format');
        }
        
        return await this.batchUpdateProgress(importData.progress);
    }
}

// Create global API instance
const api = new KoreanLearningAPI();

console.log('✅ Korean Learning API Client loaded');
console.log('📱 Your Device ID:', api.deviceId);
